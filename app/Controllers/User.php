<?php

namespace App\Controllers;

use App\Models\User_model;
use App\Models\Company_model;
use App\Models\Flow_model;

class User extends BaseController {

    function sifirla($data){
        if(empty($data)) return 0;
        else return $data;
    }

    public function dataFromExcel(){
        $this->form_validation->set_rules('flowname', 'Flow Name', 'trim|required|xss_clean');
        $this->form_validation->set_rules('epvalue', 'EP Value', 
        	"trim|required|xss_clean|strip_tags|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]");
        $this->form_validation->set_rules('epQuantityUnit', 'EP Quantity Value', 'trim|required|xss_clean');
		$kullanici = $session->get('user_in');
		
		//formats number correctly
		$quantity = str_replace(',', '.', $this->input->post('epvalue'));
		$quantity = str_replace("'", '', $quantity);

        //print_r($kullanici);
        if($this->form_validation->run() !== FALSE) {
            $epArray = array(
                    'user_id' => $kullanici['id'],
                    'flow_name' => $this->input->post('flowname'),
                    'ep_q_unit' => $this->input->post('epQuantityUnit'),
                    'ep_value' => $this->sifirla($quantity),
                );
            $this->flow_model->set_userep($epArray);
        }

        echo view('template/header');
        //echo "data from excel form";
        //echo $companyId;

		include APPPATH . 'libraries/Excel.php';
		if(file_exists('./assets/excels/'.$kullanici['username'].'.xlsx')){
			$inputFileName = './assets/excels/'.$kullanici['username'].'.xlsx';
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
        $highestColumn = $sheet->getHighestColumn();

        $excelcontents = [];
        //  Loop through each row (starts at 2, first is header line) of the worksheet in turn
        for ($row = 2; $row <= $highestRow; $row++){

            //  Read a row of data into an array
            $rowData = $sheet->rangeToArray('A' . $row . ':' . $highestColumn . $row,
                                            NULL,
                                            TRUE,
                                            FALSE);
            //  Insert row data array into your database of choice here
            //print_r($rowData[0]);
            $excelcontents[] = $rowData[0];
        }
        //echo "------";
        //print_r($excelcontents);
        $data['excelcontents'] = $excelcontents;
        $data['userepvalues']=$this->flow_model->get_userep($kullanici['id']);
		$data['units'] = $this->flow_model->get_unit_list();

        echo view('dataset/excelcontents',$data);
        echo view('template/footer');
	}
	
	public function deleteUserEp($flow_name,$ep_value){
		$kullanici = $session->get('user_in');
		$flow_name = urldecode($flow_name);
		$this->flow_model->delete_userep($flow_name,$ep_value,$kullanici['id']);
		redirect('datasetexcel', 'refresh');
	}

    public function uploadExcel(){

        $user = $session->get('user_in');
        $config['upload_path']          = './assets/excels/';
        $config['allowed_types']        = 'xlsx|xls';
        $config['max_size']             = 100;
        $config['overwrite'] = TRUE;
        $config['file_name']            = $user['username'];

        echo library('upload', $config);
        if ( ! $this->upload->do_upload('excelFile'))
        {
            $data = array('error' => $this->upload->display_errors());
            $data['id']=$user['id'];

            echo view('template/header');
            echo view('dataset/uploadexcel',$data);
            echo view('template/footer');
        }
        else
        {
            $data = array('upload_data' => $this->upload->data());
            $data['id']=$user['id'];

            echo view('template/header');
            echo view('dataset/uploadexcel',$data);
            echo view('template/footer');
        }
    }

	public function user_register(){

		$user_model = model(User_model::class);

		if(!empty($this->session->username)){
			return redirect()->to(site_url());
		}

		# TODO: recaptcha needed.
		//echo library('recaptcha');

		if(!empty($this->request->getPost())){

			if ($this->validate([
				'username'  => 'trim|required|mb_strtolower|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_user.user_name]',
				'name' => 'required|trim|max_length[50]',
				'surname' => 'required|trim|max_length[50]',
				'email' => 'required|trim|valid_email|max_length[100]|mb_strtolower|is_unique[t_user.email]',
				'password' => 'required|trim|max_length[40]',
			]))
			{

				$data = array(
					'name'=>$this->request->getPost('name'),
					'surname'=>$this->request->getPost('surname'),
					'email'=>$this->request->getPost('email'),
					'user_name'=>$this->request->getPost('username'),
					'psswrd'=>md5($this->request->getPost('password'))
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
	    return (!preg_match("/^([-a-????????????z A-????????????Z_ ])+$/i", $str)) ? FALSE : TRUE;
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

	public function user_login(){
		$user_model = model(User_model::class);
		
		if(!empty($this->session->username)){
			return redirect()->to(site_url());
		}

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'username'  => 'trim|required|min_length[3]|isTrueUserInfo',
				'password'  => 'trim|required',
			]))
			{
				$username = $this->request->getPost('username');
				$password = md5($this->request->getPost('password'));
				$userInfo = $user_model->check_user($username,$password);
				if (!empty($userInfo) && is_array($userInfo)){
					$session_array= array(
						'id' => $userInfo['id'],
						'username' => mb_strtolower($userInfo['user_name']),
						'email' => $userInfo['email'],
						'role_id' => $userInfo['role_id']
						);
					$this->session->set($session_array);
					return redirect()->to(site_url());
				}
				else{
					echo 'User info correct but returns empty value.';
					exit;
				}
			}
		}

		echo view('template/header');
		echo view('user/login_user', ['validation' => $this->validator,]);
		echo view('template/footer');
	}

	public function user_profile($username){
		$user_model = model(user_model::class);
		//permission site /user/'username' only for logged in users viewable
		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		$data['userInfo']                 = $user_model->get_userinfo_by_username($username);
		$data['projectsAsWorker']         = $user_model->get_worker_projects_from_userid($data['userInfo']['id']);
		$data['projectsAsConsultant']     = $user_model->get_consultant_projects_from_userid($data['userInfo']['id']);
		echo view('template/header');
		echo view('user/profile',$data);
		echo view('template/footer');
	}

	public function user_logout(){
		$this->session->destroy();
		return redirect()->to(site_url());
	}

	public function user_profile_update(){
		$user_model = model(User_model::class);

		$data = $user_model->get_session_user();

		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}
		$username = $this->session->username;
		
		if(!empty($this->request->getPost())){
			if ($this->validate([
				'username'  => 'trim|required|mb_strtolower|alpha_numeric|min_length[5]|max_length[50]|is_unique[t_user.user_name,id,{id}]',
				'name' => 'required|trim|max_length[50]',
				'surname' => 'required|trim|max_length[50]',
				'email' => 'required|trim|valid_email|max_length[100]|mb_strtolower|is_unique[t_user.email,id,{id}]',
			]))
			{
				$update = array(
					'id' => $data['id'],
					'name'=>$this->request->getPost('name'),
					'surname'=>$this->request->getPost('surname'),
					'email'=>$this->request->getPost('email'),
					'user_name'=>$this->request->getPost('username'),
				);
				$user_model->update_user($update);

				$session_array= array(
					'id' => $data['id'],
					'username' => $this->request->getPost('username'),
					'email' => $this->request->getPost('email')					
				);
				$this->session->set($session_array);
			}
		}

		$data['validation']=$this->validator;
		echo view('template/header');
		echo view('user/profile_update',$data);
		echo view('template/footer');
	}

	public function become_consultant(){
		$tmp = $session->get('user_in');
		if(empty($tmp) || $this->user_model->is_user_consultant($tmp['id'])){
			redirect('', 'refresh');
		}
		else{
			$this->user_model->make_user_consultant($tmp['id'],$tmp['username']);
			redirect('user/'.$tmp['username'], 'refresh');
		}
	}

	public function show_all_users(){
		//permission: site /user only for logged in users viewable
		$user = $session->get('user_in');
		if(empty($user)){
			redirect('', 'refresh');
		}

		$data['users']=$this->user_model->get_consultants();

		echo view('template/header');
		echo view('user/show_all_users',$data);
		echo view('template/footer');
	}

}
//test
?>