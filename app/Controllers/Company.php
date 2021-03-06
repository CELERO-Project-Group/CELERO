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

class Company extends BaseController {

	public function new_company(){
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);

		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		/*echo library('googlemaps');
		//alert("1:" + event.latLng.lat() + " 2:" + event.latLng.lng());
		$config['center'] = '47.566667, 7.600000'; //Basel (at center of europe)
		$config['zoom'] = '4';
		$config['map_type'] = "HYBRID";
		$config['onclick'] = '$("#latId").val("Lat:" + event.latLng.lat()); $("#longId").val("Long:" + event.latLng.lng()); $("#lat").val(event.latLng.lat()); $("#long").val(event.latLng.lng());';
		$config['places'] = TRUE;
		$config['placesRadius'] = 20;
		$this->googlemaps->initialize($config);

		$data['map'] = $this->googlemaps->create_map();*/

		if(!empty($this->request->getPost())){
			/*$this->form_validation->set_rules('companyName', 'Company Name', 'required|trim|xss_clean|mb_strtolower|max_length[254]|is_unique[t_cmpny.name]');
		$this->form_validation->set_rules('naceCode', 'Nace Code', 'required|trim|xss_clean');
		$this->form_validation->set_rules('companyDescription', 'Company Description', 'required|trim|xss_clean|max_length[200]');
		$this->form_validation->set_rules('email', 'E-mail', 'required|trim|max_length[150]|xss_clean');
		//$this->form_validation->set_rules('cellPhone', 'Cell Phone Number', 'required|trim|xss_clean');
		$this->form_validation->set_rules('workPhone', 'Work Phone Number', 'required|trim|max_length[49]|xss_clean');
		$this->form_validation->set_rules('fax', 'Fax Number', 'trim|max_length[49]|xss_clean');
		$this->form_validation->set_rules('address', 'Address', 'required|trim|xss_clean|max_length[100]');
		$this->form_validation->set_rules('lat', 'Coordinates Latitude', 'trim|required|xss_clean');
		$this->form_validation->set_rules('long', 'Coordinates Longitude', 'trim|required|xss_clean');
		$this->form_validation->set_rules('users', 'Company User', 'trim|xss_clean');
		*/
			if ($this->validate([
				'companyName'  => 'trim|required|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_cmpny.name]',
				'naceCode'  => 'trim|required',
				'companyDescription' => 'required|trim|max_length[200]',
				'email' => 'required|valid_email',
				'workPhone' => 'required'
			]))
			{

				$data = array(
					'name'=>mb_strtolower($this->request->getPost('companyName')),
					'phone_num_2'=>$this->request->getPost('workPhone'),
					'description'=>substr($this->request->getPost('companyDescription'), 0, 199),
					'email'=>$this->request->getPost('email'),
					'latitude'=>$this->request->getPost('lat'),
					'longitude'=>$this->request->getPost('long'),
					'active'=>'1'
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

				$users = $this->request->getPost('users'); // multiple select , secilen consultant'lar

				foreach ($users as $consultant) {
					$user = array(
						'user_id' => $consultant,
						'cmpny_id' => $last_id,
						'is_contact' => 0
					);
					$company_model->add_worker_to_company($user);	
				}

				$companyOwner = array(
					'user_id' => $this->session->id,
					'cmpny_id' => $last_id,
					'is_contact' => 0
				);
				$company_model->insert_cmpny_prsnl($companyOwner);
				$company_model->insert_cmpny_nace_code($cmpny_nace_code);

				}
		}
		$data['validation']=$this->validator;
		//$data['post_users']=$this->request->;

		$data['all_nace_codes'] = $company_model->get_all_nace_codes();
        $data['countries'] = $company_model->get_countries();
		$data['users']=$user_model->get_consultants();

		echo view('template/header');
		echo view('company/create_company',$data);
		echo view('template/footer');
	}

	//bu kod telefon numaralar??na - bo??luk ve _ koymaya yarar
	function alpha_dash_space($str_in = '')
	{
		if (! preg_match("/^([-a-z0-9_ ])+$/i", $str_in)){
			$this->form_validation->set_message('_alpha_dash_space', 'The %s field may only contain alpha-numeric characters, spaces, underscores, and dashes.');
			return FALSE;
		}
		else{
			return TRUE;
		}
	}

	function is_in_nace($nace)
	{
		$degisken= $this->company_model->is_in_nace($nace);

		if($degisken){
			return TRUE;
		}
		else{
			$this->form_validation->set_message('is_in_nace', 'NACE code is wrong');
			return FALSE;
		}
	}

	public function show_all_companies(){

		//permission site /companies only for logged in users viewable
		// TODO: need flash error message
		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		$company_model = model(Company_model::class);
		$cluster_model = model(Cluster_model::class);
		$user_model    = model(User_model::class);

		$cluster_id = $this->request->getPost('cluster');
		$data['help'] = "1";
		if($this->create_company_control() == FALSE){
			$data['help'] = "0";
			//redirect('', 'refresh');
		}

		if($cluster_id == null || $cluster_id == 0){
			$data['cluster_name']['name'] = lang("Validation.allcompanies");
			$data['companies'] = $company_model->get_companies();
		}
		else{
			$data['companies'] = $company_model->get_companies_with_cluster($cluster_id);
			$data['cluster_name'] = $cluster_model->get_cluster_name($cluster_id);
		}
		$data['clusters'] = $cluster_model->get_clusters();
		//permission control
		foreach ($data['companies'] as $key => $d) {
			$data['companies'][$key]['have_permission'] = $user_model->can_edit_company($this->session->id,$d['id']);
		}
		//print_r($data['companies']);
		echo view('template/header');
		echo view('company/show_all_companies',$data);
		echo view('template/footer');
	}

	public function isSelectionWithFlow($flow_id=FALSE){
		$data['flowlist'] = $this->flow_model->get_flowname_list();
		$cluster_id = $this->input->post('cluster');
		if($cluster_id == null || $cluster_id == 0){
			if(!empty($flow_id)){
				$data['cluster_name']['name'] = 'All Companies in selected flow';
				$data['companies'] = [];
				$data['companies'] = $this->company_model->get_companies_from_flow($flow_id);
			}else{
				$data['cluster_name']['name'] = 'All Companies';
				$data['companies'] = $this->company_model->get_companies();
			}
		}
		else{
			$data['companies'] = $this->company_model->get_companies_with_cluster($cluster_id);
			$data['cluster_name'] = $this->cluster_model->get_cluster_name($cluster_id);
		}
		$data['clusters'] = $this->cluster_model->get_clusters();
		//permission control
		$kullanici = $session->get('user_in');
		// foreach ($data['companies'] as $key => $d) {
		// 	$data['companies'][$key]['have_permission'] = $this->user_model->can_edit_company($kullanici['id'],$d['id']);
		// }
		//print_r($data['companies']);
		echo view('template/header');
		echo view('company/show_tuna',$data);
		echo view('template/footer');
	}

	public function show_my_companies(){
		$company_model = model(Company_model::class);

		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}
		
		$data['companies'] = $company_model->get_all_companies_i_have_rights($this->session->id);
		
		echo view('template/header');
		echo view('company/show_my_companies',$data);
		echo view('template/footer');
	}

	public function show_project_companies(){
		$project_id = $this->session->get('project_id');
		$data['companies'] = $this->company_model->get_project_companies($project_id);

		//print_r($data['companies']);
		echo view('template/header');
		echo view('company/show_project_companies',$data);
		echo view('template/footer');
	}

	public function companies($term){

		$flow_model = model(Flow_model::class);
		$process_model = model(Process_model::class);
		$component_model = model(Component_model::class);
		$equipment_model = model(Equipment_model::class);
		$product_model = model(Product_model::class);
		$company_model = model(Company_model::class);
		$user_model = model(User_model::class);

		$temp = $this->session->id;
		if($temp == null){
			$data['valid'] = "0";
		}else{
			$data['valid'] = "1";
		}
		$data['company_flows'] = $flow_model->get_company_flow_list($term);
		$data['company_prcss'] = $process_model->get_cmpny_flow_prcss($term);
		$data['company_component'] = $component_model->get_cmpnnt($term);
		$data['company_equipment'] = $equipment_model->all_information_of_equipment($term);
		$data['company_product'] = $product_model->get_product_list($term);

		$data['companies'] = $company_model->get_company($term);
		$config['center'] = $data['companies']['latitude'].','. $data['companies']['longitude'];
	    $config['zoom'] = '15';
	    $config['places'] = TRUE;
	    $config['placesRadius'] = 20;
	    $marker = array();
		$marker['position'] = $data['companies']['latitude'].','. $data['companies']['longitude'];

		$data['nacecode'] = $company_model->get_nace_code($term);
		$data['prjname'] = $company_model->get_company_proj($term);
		$data['cmpnyperson'] = $company_model->get_company_workers($term);
		$data['users_without_company']= $user_model->get_consultants();
		if(empty($data['nacecode'])){$data['nacecode']['code']="";}

		//kullan??c??n??n company'i editleme hakk?? varm?? kontrol??
		$data['have_permission'] = $user_model->can_edit_company($temp,$term);

		//checks if the company is created/owned by this user, only users that created the company can see the delete button
		$owned_cmpnys = array_column($company_model->get_my_companies($temp), 'cmpny_id');
		if(in_array($data['companies']['id'], $owned_cmpnys)){
			$data['canDelete'] = "1";
		}else{
			$data['canDelete'] = "0";
		}		

		//checks if the company is editable by this user, only users that created the company can see the edit buttons
		if($user_model->can_edit_company($temp,$term)){
			$data['canEdit'] = "1";
		}else{
			$data['canEdit'] = "0";
		}

		echo view('template/header');
		echo view('company/company_show_detailed',$data);
		echo view('template/footer');
	}


	public function company_search(){
		if (isset($_GET['term'])){
      		$q = strtolower($_GET['term']);
      		$results = $this->company_model->company_search($q);
   		}
		// and return to autocomplete
		echo $results;
	}

	public function addUsertoCompany($term){
		// check if user has a permission to edit company info
		$kullanici = $session->get('user_in');
		if(!$this->user_model->can_edit_company($kullanici['id'],$term)){
			redirect(base_url(),'refresh');
		}

		$this->form_validation->set_rules('users','User','required|callback_check_companyuser['.$term.']');
		if ($this->form_validation->run() !== FALSE)
		{
			$user = array(
				'user_id' => $this->input->post('users'),
      			'cmpny_id' => $term,
      			'is_contact' => 0
    		);
    	$this->company_model->add_worker_to_company($user);
		}

		redirect('company/'.$term, 'refresh');

	}

	function check_companyuser($str,$term) {
		return !$this->user_model->can_edit_company($str,$term);
	}

	public function removeUserfromCompany($term,$selected_user_id){
		// check if user has a permission to edit company info, if not redirects to main page.
		$user = $session->get('user_in');
		if(!$this->user_model->can_edit_company($user['id'],$term)){
			redirect(base_url(),'refresh');
		}

		$user = array(
			'user_id' => $selected_user_id,
			'cmpny_id' => $term,
			'is_contact' => 0
		);
    	$this->company_model->remove_worker_to_company($user);
		redirect('company/'.$term, 'refresh');

	}

	public function update_company($term){

		
		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);

		//kullan??c??n??n company'i editleme hakk?? varm?? kontrol??
		$id = $this->session->id;
		if(!$user_model->can_edit_company($id,$term)){
			return redirect()->to(site_url());
		}

		
		$data['companies'] = $company_model->get_company($term);
		$data['nace_code'] = $company_model->get_nace_code($term);
		$data['all_nace_codes'] = $company_model->get_all_nace_codes();

		if(empty($data['nace_code'])){$data['nace_code']['code']="";}


		if(!empty($this->request->getPost())){
			if ($this->validate([
				'companyName'  => 'required|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_cmpny.name,id,{id}]',
				'naceCode'  => 'required',
				'companyDescription' => 'required|max_length[200]',
				'email' => 'required|valid_email',
				'workPhone' => 'required'
			])){

				$company_data = array(
					'name'=>mb_strtolower($this->request->getPost('companyName')),
					'phone_num_2'=>$this->request->getPost('workPhone'),
					'description'=>substr($this->request->getPost('companyDescription'), 0, 199),
					'email'=>$this->request->getPost('email'),
					'latitude'=>$this->request->getPost('lat'),
					'longitude'=>$this->request->getPost('long'),
				);

				$company_model->update_company($company_data,$term);

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

				
		  		$company_model->update_cmpny_data($cmpny_data,$data['companies']['id']);
		    	$company_model->update_cmpny_nace_code($cmpny_nace_code,$data['companies']['id']);

				return redirect()->to(site_url('company/'.$data['companies']['id']));

			}
			
	  	}
		
		$data['validation']=$this->validator;

		echo view('template/header');
		echo view('company/update_company',$data);
		echo view('template/footer');
	}

	public function create_company_control(){
		$user_model = model(User_model::class);
		$cmpny = $user_model->cmpny_prsnl($this->session->id);

		if(empty($cmpny)){
			return TRUE;
		}
		else{
			return FALSE;
		}
	}


	public function get_company_info($company_id){
		$data['company_info'] = $this->company_model->get_company($company_id);
		$data['company_flows'] = $this->flow_model->get_company_flow_list($company_id);
		$data['company_prcss'] = $this->process_model->get_cmpny_flow_prcss($company_id);
		$data['company_component'] = $this->component_model->get_cmpnnt($company_id);
		$data['company_equipment'] = $this->equipment_model->all_information_of_equipment($company_id);
		$data['company_product'] = $this->product_model->get_product_list($company_id);
		header("Content-Type: application/json", true);
		echo json_encode($data);
	}

	//delet company (if user is owner/creator of company)
	public function delete_company($cmpny_id){
		$temp = $session->get('user_in');
		$owned_cmpnys = array_column($this->company_model->get_my_companies($temp['id']), 'cmpny_id');
		if(in_array($cmpny_id, $owned_cmpnys)){
			$this->company_model->delete_company($cmpny_id);
			redirect(base_url('mycompanies'),'refresh');
		}else{
			redirect(base_url(''),'refresh');
		}	
	}
}
?>
