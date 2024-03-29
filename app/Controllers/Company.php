<?php

namespace App\Controllers;

use App\Models\Company_model;
use App\Models\User_model;
use App\Models\Cluster_model;
use App\Models\Flow_model;
use App\Models\Process_model;
use App\Models\Component_model;
use App\Models\Equipment_model;
use App\Models\Product_model;

class Company extends BaseController
{


	public function new_company()
	{
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);
		$session = session();


		if (empty($session->username)) {

			return redirect()->to(site_url());
		}
		if (!empty($this->request->getPost())) {
			if (
				$this->validate(
					[
						'companyName' => [
							'rules' => 'trim|required|alpha_numeric_space|min_length[5]|max_length[50]|is_unique[t_cmpny.name]',
							'label' => 'Company Name'
						],

						'naceCode' =>
							[
								'rules' => 'trim|required',
								'label' => 'NACE Code'
							],

						'country' =>
							[
								'rules' => 'required',
								'errors' => [
									'required' => 'Country is not selected'
								]
							],

						'email' =>
							['rules' => 'required|valid_email'],

						'workPhone' =>
							[
								'rules' => 'required',
								'label' => 'Work Phone'
							],

						'lat' =>
							[
								'rules' => 'required',
								'errors' => [
									'required' => 'Location is not selected on the map'
								]
							],

						'companyDescription' =>
							[
								'rules' => 'required|trim|max_length[200]',
								'label' => 'Company Description'
							],

						'users' =>
							[
								'rules' => 'required',
								'errors' => [
									'required' => 'Consultant is not selected'
								]
							],
					]
				)
			) {
				// getting address directly from lat and long
				// Replace with your actual latitude and longitude
				$latitude = $this->request->getPost('lat');
				$longitude = $this->request->getPost('long');
				// Construct the URL
				$url = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" . $latitude . "&lon=" . $longitude;

				// Add User-Agent header
				$options = array(
					'http' => array(
						'header' => "User-Agent: MyApplication/1.0\r\n"
					)
				);
				$context = stream_context_create($options);

				// Fetch the address data
				$response = file_get_contents($url, false, $context);
				$address_data = json_decode($response, true);

				// print_r($address_data['display_name']);

				$data = array(
					'name' => mb_strtolower($this->request->getPost('companyName')),
					'phone_num_2' => $this->request->getPost('workPhone'),
					'description' => substr($this->request->getPost('companyDescription'), 0, 199),
					'email' => $this->request->getPost('email'),
					'latitude' => $latitude,
					'longitude' => $longitude,
					'address' => $address_data['display_name'],
					'active' => '1'
				);

				$code = $this->request->getPost('naceCode');
				$last_id = $company_model->insert_company($data);
				$cmpny_data = array(
					'cmpny_id' => $last_id,
					'description' => substr($data['description'], 0, 199)
				);

				$nace_code_id = $company_model->search_nace_code($code);

				$cmpny_nace_code = array(
					'cmpny_id' => $last_id,
					'nace_code_id' => $nace_code_id['id']
				);

				$users = $this->request->getPost('users');

				if (count($users) > 0) {
					foreach ($users as $consultant) {
						$user = array(
							'user_id' => $consultant,
							'cmpny_id' => $last_id,
							'is_contact' => 0,
							'is_owner' => 0,
						);

						//check if the current user is trying to add himself to the list -> user will be added in another function
						if ($user['user_id'] != $session->id) {
							$company_model->add_worker_to_company($user);
						}
					}
				}

				$companyOwner = array(
					'user_id' => $session->id,
					'cmpny_id' => $last_id,
					'is_contact' => 0,
					'is_owner' => 1
				);

				// Check if the person is already connected to this company. If not add the person also.
				if (!$company_model->user_exists_in_company($companyOwner)) {
					$company_model->insert_cmpny_prsnl($companyOwner);
				}


				$company_model->insert_cmpny_nace_code($cmpny_nace_code);

				//return redirect()->to("company/$companyOwner[cmpny_id]");
			}
		}


		$data['validation'] = $this->validator;
		//$data['post_users']=$this->request->;

		$data['all_nace_codes'] = $company_model->get_all_nace_codes();
		$data['countries'] = $company_model->get_countries();
		$data['users'] = $user_model->get_consultants();

		echo view('template/header');
		echo view('company/create_company', $data);
		echo view('template/footer');
	}

	//bu kod telefon numaralarına - boşluk ve _ koymaya yarar
	function alpha_dash_space($str_in = '')
	{
		if (!preg_match("/^([-a-z0-9_ ])+$/i", $str_in)) {
			$this->form_validation->set_message('_alpha_dash_space', 'The %s field may only contain alpha-numeric characters, spaces, underscores, and dashes.');
			return FALSE;
		} else {
			return TRUE;
		}
	}

	function is_in_nace($nace)
	{
		$company_model = model(Company_model::class);
		$degisken = $company_model->is_in_nace($nace);

		if ($degisken) {
			return TRUE;
		} else {
			$this->form_validation->set_message('is_in_nace', 'NACE code is wrong');
			return FALSE;
		}
	}

	public function show_all_companies()
	{
		$session = session();

		if (empty($session->username)) {
			return redirect()->to(site_url());
		}

		$company_model = model(Company_model::class);
		$cluster_model = model(Cluster_model::class);
		$user_model = model(User_model::class);

		// get the cmpny data with the owner ship
		$userId = $session->id;
		$is_owner = $user_model->cmpny_is_owner($userId);


		$cluster_id = $this->request->getPost('cluster');
		$data['help'] = "1";
		if ($this->create_company_control() == FALSE) {
			$data['help'] = "0";
		}

		if ($cluster_id == null || $cluster_id == 0) {
			$data['cluster_name']['name'] = lang("Validation.allcompanies");
			$data['companies'] = $company_model->get_companies();
		} else {
			$data['companies'] = $company_model->get_companies_with_cluster($cluster_id);
			$data['cluster_name'] = $cluster_model->get_cluster_name($cluster_id);
		}
		$data['clusters'] = $cluster_model->get_clusters();
		//permission control
		foreach ($data['companies'] as $key => $d) {
			$data['companies'][$key]['have_permission'] = $user_model->can_edit_company($userId, $d['id'], $is_owner);
		}
		//print_r($data['companies']);
		echo view('template/header');
		echo view('company/show_all_companies', $data);
		echo view('template/footer');
	}

	public function isSelectionWithFlow($flow_id = FALSE)
	{
		$flow_model = model(Flow_model::class);
		$company_model = model(Company_model::class);
		$session = session();
		$project_id = $session->get('project_id');

		$data['flowlist'] = $flow_model->get_flowname_list();

		if (!empty($flow_id)) {
			$data['cluster_name']['name'] = 'All Companies in selected flow';
			$data['companies'] = [];
			$data['companies'] = $company_model->get_project_companies_with_flow($project_id, $flow_id);
		} else {
			$data['cluster_name']['name'] = 'All Project Companies';
			$data['companies'] = $company_model->get_project_companies($project_id);
		}

		echo view('template/header');
		echo view('company/isscoping', $data);
		echo view('template/footer');
	}

	public function show_my_companies()
	{
		$company_model = model(Company_model::class);
		$session = session();

		if (empty($session->username)) {
			return redirect()->to(site_url());
		}

		$data['companies'] = $company_model->get_all_companies_i_have_rights($session->id);

		echo view('template/header');
		echo view('company/show_my_companies', $data);
		echo view('template/footer');
	}

	public function show_project_companies()
	{
		// $company_model = model(Company_model::class);
		// $project_id = $this->session->get('project_id');
		$company_model = model(Company_model::class);
		$session = session();
		$project_id = $session->get('project_id');
		$data['companies'] = $company_model->get_project_companies($project_id);

		echo view('template/header');
		echo view('company/show_project_companies', $data);
		echo view('template/footer');
	}

	public function companies($term)
	{
		$flow_model = model(Flow_model::class);
		$process_model = model(Process_model::class);
		$component_model = model(Component_model::class);
		$equipment_model = model(Equipment_model::class);
		$product_model = model(Product_model::class);
		$company_model = model(Company_model::class);
		$user_model = model(User_model::class);

		$session = session();

		$temp = $session->id;
		if ($temp == null) {
			$data['valid'] = "0";
		} else {
			$data['valid'] = "1";
		}
		$data['company_flows'] = $flow_model->get_company_flow_list($term);
		$data['company_prcss'] = $process_model->get_cmpny_flow_prcss($term);
		$data['company_component'] = $component_model->get_cmpnnt($term);
		$data['company_equipment'] = $equipment_model->all_information_of_equipment($term);
		$data['company_product'] = $product_model->get_product_list($term);

		$data['companies'] = $company_model->get_company($term);

		// $config['center'] = $data['companies']['latitude'] . ',' . $data['companies']['longitude'];
		// $config['zoom'] = '15';
		// $config['places'] = TRUE;
		// $config['placesRadius'] = 20;
		// $marker = array();
		// $marker['position'] = $data['companies']['latitude'] . ',' . $data['companies']['longitude'];

		$data['nacecode'] = $company_model->get_nace_code($term);
		$data['prjname'] = $company_model->get_company_proj($term);
		$data['cmpnyperson'] = $company_model->get_company_workers($term);
		$data['users_without_company'] = $user_model->get_consultants();
		if (empty($data['nacecode'])) {
			$data['nacecode']['code'] = "";
		}

		$is_owner = $user_model->cmpny_is_owner($temp);

		//kullanıcının company'i editleme hakkı varmı kontrolü
		$data['have_permission'] = $user_model->can_edit_company($temp, $term, $is_owner);

		//checks if the company is created/owned by this user, only users that created the company can see the delete button
		$owned_cmpnys = array_column($company_model->get_my_companies($temp), 'cmpny_id');
		if (in_array($data['companies']['id'], $owned_cmpnys)) {
			$data['canDelete'] = "1";
		} else {
			$data['canDelete'] = "0";
		}

		//checks if the company is editable by this user, only users that created the company can see the edit buttons
		if ($user_model->can_edit_company($temp, $term, $is_owner)) {
			$data['canEdit'] = "1";
		} else {
			$data['canEdit'] = "0";
		}

		echo view('template/header');
		echo view('company/company_show_detailed', $data);
		echo view('template/footer');
	}


	public function company_search()
	{
		$company_model = model(Company_model::class);
		if (isset($_GET['term'])) {
			$q = strtolower($_GET['term']);
			$results = $company_model->company_search($q);
		}
		// and return to autocomplete
		echo $results;
	}

	public function addUsertoCompany($cmpny_id)
	{
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);
		$session = session();
		// $validation = \Config\Services::validation();

		$userId = $session->id;
		$is_owner = $user_model->cmpny_is_owner($userId);
		if (!$user_model->can_edit_company($userId, $cmpny_id, $is_owner)) {

			return redirect()->to(base_url());
		}

		$selected_user = $this->request->getPost('users');

		//$this->form_validation->set_rules('users','User','required|callback_check_companyuser['.$term.']');
		//if ($validation->run() !== FALSE) {
		$user = array(
			'user_id' => $selected_user,
			'cmpny_id' => $cmpny_id,
			'is_contact' => 0,
			'is_owner' => 0
		);


		if (!$company_model->user_exists_in_company($user)) {
			$company_model->add_worker_to_company($user);
		}
		//}

		//redirect('company/'.$term, 'refresh');
		return redirect()->to(site_url('company/' . $cmpny_id));
		// return redirect()->to(site_url('www.google.com'));

	}

	function check_companyuser($str, $term)
	{
		$user_model = model(User_model::class);
		$is_owner = $user_model->cmpny_is_owner($str);
		return !$user_model->can_edit_company($str, $term, $is_owner);
	}

	public function removeUserfromCompany($cmpny_id, $selected_user_id)
	{
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);
		$session = session();

		$userId = $session->id;
		$cmpny = $user_model->cmpny_prsnl($userId);
		$is_owner = $user_model->cmpny_is_owner($userId);

		//TODO change the redirect to something like "you don't have the rights to do this!"
		if (!$user_model->can_edit_company($userId, $cmpny['cmpny_id'], $is_owner)) {
			// redirect(base_url(),'refresh');
			return redirect()->to(site_url('company/' . $cmpny_id));
		}

		$user = array(
			'user_id' => $selected_user_id,
			'cmpny_id' => $cmpny_id,
			'is_contact' => 0
		);

		$company_model->remove_worker_from_company($user);
		// redirect('company/'.$term, 'refresh');
		return redirect()->to(site_url('company/' . $cmpny_id));
	}

	public function update_company($term)
	{
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);
		$session = session();

		//kullanýcýnýn company'i editleme hakký varmý kontrolü
		$id = $session->id;

		$is_owner = $user_model->cmpny_is_owner($id);

		if (!$user_model->can_edit_company($id, $term, $is_owner)) {
			return redirect()->to(site_url());
		}

		$data['companies'] = $company_model->get_company($term);
		$data['nace_code'] = $company_model->get_nace_code($term);
		$data['all_nace_codes'] = $company_model->get_all_nace_codes();

		if (empty($data['nace_code'])) {
			$data['nace_code']['code'] = "";
		}


		if (!empty($this->request->getPost())) {
			if (
				$this->validate(
					[
						'companyName' => [
							'rules' => 'trim|required|alpha_numeric_space|min_length[5]|max_length[50]',
							'label' => 'Company Name'
						],

						'naceCode' =>
							[
								'rules' => 'trim|required',
								'label' => 'NACE Code'
							],


						'email' =>
							['rules' => 'required|valid_email'],

						'workPhone' =>
							[
								'rules' => 'required',
								'label' => 'Work Phone'
							],

						'lat' =>
							[
								'rules' => 'required',
								'errors' => [
									'required' => 'Location is not selected on the map'
								]
							],

						'companyDescription' =>
							[
								'rules' => 'required|trim|max_length[200]',
								'label' => 'Company Description'
							],

					]
				)


			) {
				$latitude = $this->request->getPost('lat');
				$longitude = $this->request->getPost('long');

				$url = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" . $latitude . "&lon=" . $longitude;

				// Add User-Agent header
				$options = array(
					'http' => array(
						'header' => "User-Agent: MyApplication/1.0\r\n"
					)
				);
				$context = stream_context_create($options);

				// Fetch the address data
				$response = file_get_contents($url, false, $context);
				$address_data = json_decode($response, true);

				$company_data = array(
					'name' => mb_strtolower($this->request->getPost('companyName')),
					'phone_num_2' => $this->request->getPost('workPhone'),
					'description' => substr($this->request->getPost('companyDescription'), 0, 199),
					'email' => $this->request->getPost('email'),
					'latitude' => $latitude,
					'longitude' => $longitude,
					'address' => $address_data['display_name'],
				);

				$company_model->update_company($company_data, $term);

				$code = $this->request->getPost('naceCode');
				$nace_code_id = $company_model->search_nace_code($code);
				$cmpny_nace_code = array(
					'cmpny_id' => $data['companies']['id'],
					'nace_code_id' => $nace_code_id['id']
				);


				$cmpny_data = array(
					'cmpny_id' => $data['companies']['id'],
					'description' => substr($data['companies']['description'], 0, 199)
				);


				$company_model->update_cmpny_data($cmpny_data, $data['companies']['id']);
				$company_model->update_cmpny_nace_code($cmpny_nace_code, $data['companies']['id']);

				return redirect()->to(site_url('company/' . $data['companies']['id']));

			}

		}

		$data['validation'] = $this->validator;

		echo view('template/header');
		echo view('company/update_company', $data);
		echo view('template/footer');
	}

	public function create_company_control()
	{
		$user_model = model(User_model::class);
		$session = session();
		$cmpny = $user_model->cmpny_prsnl($session->id);

		if (empty($cmpny)) {
			return TRUE;
		} else {
			return FALSE;
		}
	}


	public function get_company_info($company_id)
	{
		$company_model = model(Company_model::class);
		$flow_model = model(Flow_model::class);
		$process_model = model(Process_model::class);
		$component_model = model(Component_model::class);
		$equipment_model = model(Equipment_model::class);
		$product_model = model(Product_model::class);

		$data['company_info'] = $company_model->get_company($company_id);
		$data['company_flows'] = $flow_model->get_company_flow_list($company_id);
		$data['company_prcss'] = $process_model->get_cmpny_flow_prcss($company_id);
		$data['company_component'] = $component_model->get_cmpnnt($company_id);
		$data['company_equipment'] = $equipment_model->all_information_of_equipment($company_id);
		$data['company_product'] = $product_model->get_product_list($company_id);
		header("Content-Type: application/json", true);
		echo json_encode($data);
	}

	//delet company (if user is owner/creator of company)
	public function delete_company($cmpny_id)
	{
		$company_model = model(Company_model::class);
		$session = session();
		$userId = $session->id;
		$owned_cmpnys = array_column($company_model->get_my_companies($userId), 'cmpny_id');
		if (in_array($cmpny_id, $owned_cmpnys)) {
			$company_model->delete_company($cmpny_id);
			// redirect(base_url('mycompanies'),'refresh');
			return redirect()->to(base_url('mycompanies'));


		} else {
			return redirect()->to(site_url());
		}
	}


}
?>