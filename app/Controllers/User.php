<?php

namespace App\Controllers;

use App\Models\User_model;
use App\Models\Company_model;
use App\Models\Flow_model;

use \PhpOffice\PhpSpreadsheet\IOFactory;


class User extends BaseController
{

	function sifirla($data)
	{
		if (empty($data))
			return 0;
		else
			return $data;
	}

	public function dataFromExcel()
	{
		$flow_model = model(Flow_model::class);

		$userid = $this->session->id;
		// $username = $this->session->username;
		
		// retrieve data from excel if in the same session a file was uploaded
		$xlsArray = session()->get('xlsArray') ?? [];
		
		if (!empty($this->request->getPost())) {
			$formId = $this->request->getPost('form_id');

			if ($formId === 'form1' || $formId === 'form2') {

				if (
					$this->validate([
						'flowname' => 'trim|required',
						'epvalue' => "required|trim|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]",
						'epQuantityUnit' => 'required|trim'
					])
				) {
					//formats number correctly
					$quantity = str_replace(',', '.', $this->request->getPost('epvalue'));
					$quantity = str_replace("'", '', $quantity);

					$epArray = array(
						'user_id' => $userid,
						'flow_name' => $this->request->getPost('flowname'),
						'ep_q_unit' => $this->request->getPost('epQuantityUnit'),
						'ep_value' => $this->sifirla($quantity),
					);
					$flow_model->set_userep($epArray);

					/* include APPPATH . 'libraries/Excel.php';
																										   if(file_exists('./assets/excels/'.$username.'.xlsx')){
																											   $inputFileName = './assets/excels/'.$username.'.xlsx';
																										   }else{
																											   $inputFileName = './assets/excels/default.xlsx';
																										   }

																										   //  Read your Excel workbook
																										   try {
																											   $inputFileType = PHPExcel_IOFactory::identify($inputFileName);
																											   $objReader = PHPExcel_IOFactory::createReader($inputFileType);
																											   $objPHPExcel = $objReader->load($inputFileName);
																										   } catch(Exception $e) {
																											   die('Error loading file "'.pathinfo($inputFileName,PATHINFO_BASENAME).'": '.$e->getMessage());
																										   }

																										   //  Get worksheet dimensions
																										   $sheet = $objPHPExcel->getSheet(0);
																										   $highestRow = $sheet->getHighestRow();
																										   $highestColumn = $sheet->getHighestColumn(); */

					//  Loop through each row (starts at 2, first is header line) of the worksheet in turn
					/* for ($row = 2; $row <= $highestRow; $row++){

																											   //  Read a row of data into an array
																											   $rowData = $sheet->rangeToArray('A' . $row . ':' . $highestColumn . $row,
																																			   NULL,
																																			   TRUE,
																																			   FALSE);
																											   //  Insert row data array into your database of choice here
																											   //print_r($rowData[0]);
																											   $excelcontents[] = $rowData[0];
																										   } */
					//echo "------";
					//print_r($);
				}
			} else {

				# validation for import of excel file
				$input = $this->validate([
					'excelFile' => [
						'rules' => 'uploaded[excelFile]|max_size[excelFile,100]|ext_in[excelFile,xlsx,xls]',
						'label' => "Excel File"
					]
				]);

				if ($file = $this->request->getFile('excelFile')) {

					try {
						// Validate file type
						if ($file->getClientMimeType() !== 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
							throw new Exception('Invalid file format. Only Excel files (XLSX) are allowed.');
						}

						// Load the Excel file using PhpSpreadsheet
						$reader = IOFactory::load($file);
						$spreadsheet = $reader->getActiveSheet();

						// Iterate through rows and cells
						$data = [];
						foreach ($spreadsheet->getRowIterator() as $row) {
							$rowData = [];
							foreach ($row->getCellIterator() as $cell) {
								$value = $cell->getCalculatedValue();
								if (!empty($value)) {
									$rowData[] = $value;
								}
							}
							if (!empty($rowData)) { // Check if row itself is not empty
								$data[] = $rowData;
							}
						}

						$data = array_slice($data, 1);

						// $output = json_encode($data);
						// echo "<script type='text/javascript'>console.log($output);</script>";

						$count = 0;

						foreach ($data as $row) {

							$rowData = array(
								'user_id' => $userid,
								'flow_name' => $row[0],
								'ep_q_unit' => $row[2],
								'ep_value' => $row[1],
								'ep_q_unit_id' => $row[3]
							);

							$xlsArray[] = $rowData;
							$count++;
						}

						session()->set('xlsArray', $xlsArray);


						$this->session->setFlashdata("message", $count . " rows successfully added.");
						$this->session->setFlashdata('alert-class', 'alert-success');


					} catch (Exception $e) {
						// Handle exceptions gracefully, e.g., display error messages or log errors
						$this->session->setFlashdata('error', $e->getMessage());

					}

				}



			}
		}


		$data['validation'] = $this->validator;
		$data['excelcontents'] = $xlsArray;
		$data['userepvalues'] = $flow_model->get_userep($userid);
		$data['units'] = $flow_model->get_unit_list();
		echo view('template/header');
		echo view('dataset/excelcontents', $data);
		echo view('template/footer');
	}

	public function clearList(){
		session()->remove('xlsArray');

		return redirect()->back()->with('success', 'List cleared successfully.');
	}

	public function deleteUserEp($flow_name, $ep_value)
	{
		$flow_model = model(Flow_model::class);

		$userId = session()->get('id');
		$flow_name = urldecode($flow_name);

		$flow_model->delete_userep($flow_name, $ep_value, $userId);

		return redirect()->to('datasetexcel');
	}




	// public function uploadExcel()
	// {
	// 	$userid = session()->get('id');
	// 	$username = session()->get('username');

	// 	$validation = \Config\Services::validation();

	// 	$validation->setRules([
	// 		'excelFile' => [
	// 		'rules'=> 'uploaded[excelFile]|max_size[excelFile,100]|mime_in[excelFile,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel]|ext_in[excelFile,xlsx,xls]',
	// 		'label'=> "Excel File"]			
	// 	]);

	// 	if ($validation->withRequest($this->request)->run()) {
	// 		$excelFile = $this->request->getFile('excelFile');

	// 		$config = [
	// 			'upload_path' => './assets/excels/',
	// 			'allowed_types' => 'xlsx|xls',
	// 			'max_size' => 100,
	// 			'overwrite' => TRUE,
	// 			'file_name' => $username,
	// 		];

	// 		$excelFile->move($config['upload_path'], $config['file_name']);

	// 		if ($excelFile->getError() == UPLOAD_ERR_OK) {
	// 			$data = [
	// 				'upload_data' => $excelFile->getName(),
	// 				'id' => $userid,
	// 			];

	// 			return view('template/header') . view('dataset/uploadexcel', $data) . view('template/footer');
	// 		} else {
	// 			$data = [
	// 				'error' => $excelFile->getErrorString(),
	// 				'id' => $userid,
	// 			];

	// 			return view('template/header') . view('dataset/uploadexcel', $data) . view('template/footer');
	// 		}
	// 	} else {
	// 		$data = [
	// 			'error' => $validation->getError(),
	// 			'id' => $userid,
	// 		];

	// 		return view('template/header') . view('dataset/uploadexcel', $data) . view('template/footer');
	// 	}
	// }

	public function uploadExcel()
	{

		$userid = $this->session->id;

		$input = $this->validate([
			'excelFile' => [
				'rules' => 'uploaded[excelFile]|max_size[excelFile,100]|ext_in[excelFile,xlsx,xls]',
				'label' => "Excel File"
			]
		]);

		if (!$input) {
			$data['validation'] = $this->validator;
			return view('template/header') . view('dataset/uploadexcel', $data) . view('template/footer');
		} else {
			if ($file = $this->request->getFile('excelFile')) {

				try {
					// Validate file type
					if ($file->getClientMimeType() !== 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
						throw new Exception('Invalid file format. Only Excel files (XLSX) are allowed.');
					}

					// Load the Excel file using PhpSpreadsheet
					$reader = IOFactory::load($file);
					$spreadsheet = $reader->getActiveSheet();

					// Iterate through rows and cells
					$data = [];
					foreach ($spreadsheet->getRowIterator() as $row) {
						$rowData = [];
						foreach ($row->getCellIterator() as $cell) {
							$value = $cell->getCalculatedValue();
							if (!empty($value)) {
								$rowData[] = $value;
							}
						}
						if (!empty($rowData)) { // Check if row itself is not empty
							$data[] = $rowData;
						}
					}

					$data = array_slice($data, 1);

					// $output = json_encode($data);
					// echo "<script type='text/javascript'>console.log($output);</script>";

					$count = 0;
					$epArray = array();
					foreach ($data as $row) {

						$epArray = array(
							'user_id' => $userid,
							'flow_name' => $row[0],
							'ep_q_unit' => $row[3],
							'ep_value' => $row[1]
						);
						// $flow_model->set_userep($epArray);

						$count++;
					}

					$this->session->setFlashdata("message", $count . " rows successfully added.");
					$this->session->setFlashdata('alert-class', 'alert-success');


				} catch (Exception $e) {
					// Handle exceptions gracefully, e.g., display error messages or log errors
					$this->session->setFlashdata('error', $e->getMessage());

				}

			}


		}
	}



	public function user_register()
	{

		$user_model = model(User_model::class);

		if (!empty($this->session->username)) {
			return redirect()->to(site_url());
		}

		if (!empty($this->request->getPost())) {

			if (
				$this->validate([
					'username' => 'trim|required|mb_strtolower|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_user.user_name]',
					'name' => 'required|trim|max_length[50]',
					'surname' => 'required|trim|max_length[50]',
					'email' => 'required|trim|valid_email|max_length[100]|mb_strtolower|is_unique[t_user.email]',
					'password' => 'required|trim|max_length[40]',
				])
			) {

				$data = array(
					'name' => $this->request->getPost('name'),
					'surname' => $this->request->getPost('surname'),
					'email' => $this->request->getPost('email'),
					'user_name' => $this->request->getPost('username'),
					'psswrd' => md5($this->request->getPost('password'))
				);
				$last_inserted_user_id = $user_model->create_user($data);
				return redirect()->to("completed");

			}
		}

		echo view('template/header');
		echo view('user/create_user', ['validation' => $this->validator,]);
		echo view('template/footer');
	}

	function string_control($str)
	{
		return (!preg_match("/^([-a-üöçşığz A-ÜÖÇŞİĞZ_ ])+$/i", $str)) ? FALSE : TRUE;
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

	public function user_login()
	{
		$user_model = model(User_model::class);

		if (!empty($this->session->username)) {
			return redirect()->to(site_url());
		}

		if (!empty($this->request->getPost())) {
			if (
				$this->validate([
					'username' => 'trim|required|min_length[3]|isTrueUserInfo',
					'password' => 'trim|required',
				])
			) {
				$username = $this->request->getPost('username');
				$password = md5($this->request->getPost('password'));
				$userInfo = $user_model->check_user($username, $password);
				if (!empty($userInfo) && is_array($userInfo)) {
					$session_array = array(
						'id' => $userInfo['id'],
						'username' => mb_strtolower($userInfo['user_name']),
						'email' => $userInfo['email'],
						'role_id' => $userInfo['role_id']
					);
					$this->session->set($session_array);
					return redirect()->to(site_url());
				} else {
					echo 'User info correct but returns empty value.';
					exit;
				}
			}
		}

		echo view('template/header');
		echo view('user/login_user', ['validation' => $this->validator,]);
		echo view('template/footer');
	}

	public function user_profile($username)
	{
		$user_model = model(user_model::class);
		//permission site /user/'username' only for logged in users viewable
		if (empty($this->session->username)) {
			return redirect()->to(site_url());
		}

		$data['userInfo'] = $user_model->get_userinfo_by_username($username);
		$data['projectsAsWorker'] = $user_model->get_worker_projects_from_userid($data['userInfo']['id']);
		$data['projectsAsConsultant'] = $user_model->get_consultant_projects_from_userid($data['userInfo']['id']);
		echo view('template/header');
		echo view('user/profile', $data);
		echo view('template/footer');
	}

	public function user_logout()
	{
		$this->session->destroy();
		return redirect()->to(site_url());
	}

	public function user_profile_update()
	{
		$user_model = model(User_model::class);

		$data = $user_model->get_session_user();

		if (empty($this->session->username)) {
			return redirect()->to(site_url());
		}
		$username = $this->session->username;

		if (!empty($this->request->getPost())) {
			if (
				$this->validate([
					'username' => 'trim|required|mb_strtolower|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_user.user_name,id,{id}]',
					'name' => 'required|trim|max_length[50]',
					'surname' => 'required|trim|max_length[50]',
					'email' => 'required|trim|valid_email|max_length[100]|mb_strtolower|is_unique[t_user.email,id,{id}]',
				])
			) {
				$update = array(
					'id' => $data['id'],
					'name' => $this->request->getPost('name'),
					'surname' => $this->request->getPost('surname'),
					'email' => $this->request->getPost('email'),
					'user_name' => $this->request->getPost('username'),
				);
				$user_model->update_user($update);

				$session_array = array(
					'id' => $data['id'],
					'username' => $this->request->getPost('username'),
					'email' => $this->request->getPost('email')
				);
				$this->session->set($session_array);
			}
		}

		$data['validation'] = $this->validator;
		echo view('template/header');
		echo view('user/profile_update', $data);
		echo view('template/footer');
	}

	public function become_consultant()
	{
		$user_model = model(User_model::class);

		$userid = $this->session->id;
		$username = $this->session->username;
		if (empty($tmp) || $user_model->is_user_consultant($userid)) {
			return redirect()->to(site_url());
		} else {
			$user_model->make_user_consultant($userid, $username);
			return redirect()->to(site_url('user/' . $username));
		}
	}

	public function show_all_users()
	{
		$user_model = model(User_model::class);
		
		// if not admin redirect to main page
		if ($this->session->role_id != 3) {
			return redirect()->to(site_url());
		}
		$data['consultant'] = $user_model->get_consultants();
		$data['visitors'] = $user_model->get_visitors();
		$data['admin'] = $user_model->get_admin();
		$data['departmentmanager'] = $user_model->get_departmentmanager();
		$data['departmentworker'] = $user_model->get_departmentworker();
		echo view('template/header');
		echo view('user/show_all_users', $data);
		echo view('template/footer');
	}

}
?>