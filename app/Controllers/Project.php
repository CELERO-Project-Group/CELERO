<?php

namespace App\Controllers;

use App\Models\Project_model;
use App\Models\Company_model;
use App\Models\User_model;

# TODO: every method needs user login check.
class Project extends BaseController{

	public function open_project(){

		$user_model = model(User_model::class);
		$project_model = model(Project_model::class);

		$userId = $this->session->id;
		$is_consultant = $user_model->is_user_consultant($userId);
		if(!$is_consultant){
			$this->session->set_flashdata('project_error', '<i class="fa fa-exclamation-circle"></i> Sorry, you dont have permission to open this project.');
			redirect('project', 'refresh');
		}

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'projectid'  => 'required',
			]))
			{
				$projectId = $this->request->getPost('projectid');
				$session_array= array(
					'project_id' => $projectId,
					'project_name' => $project_model->get_project($projectId)
					);
				$this->session->set($session_array);
				return redirect()->to(site_url('project/'.$projectId));
			}
		}
		$data['projects'] = $project_model->get_consultant_projects($userId);
		echo view('template/header');
		echo view('project/open_project',$data);
		echo view('template/footer');
	}

	// removes project sessions
	public function close_project(){
		session()->remove('project_id');
		session()->remove('project_name');
		return redirect()->to(site_url('myprojects'));
	}

	public function new_project(){

		
		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		$user_model = model(User_model::class);
		$company_model = model(Company_model::class);
		$project_model = model(Project_model::class);

		$userId = $this->session->id;
		$data['companies']=$company_model->get_my_companies($userId);
		$data['consultants']=$user_model->get_consultants();
		$data['project_status']=$project_model->get_active_project_status();

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'projectName'  => 'trim|required|max_length[200]|is_unique[t_prj.name]',
				'description'  => 'trim|required|max_length[200]',
				'assignCompany' => 'required',
				'assignConsultant' => 'required',
				'assignContactPerson' => 'required'
			]))
			{
				$project = array(
				'name'=>$this->request->getPost('projectName'),
				'description'=>$this->request->getPost('description'),
				'start_date'=>date('Y-m-d', strtotime(str_replace('-', '/', $this->request->getPost('datepicker')))), // mysql icin format�n� ayarlad�k
				'status_id'=>$this->request->getPost('status'),
				'active'=>1, //default active:1 olarak kaydediyoruz.
				);
				

				$last_inserted_project_id = $project_model->create_project($project);


				$companies = array ($this->request->getPost('assignCompany')); // multiple select , secilen company'ler

				foreach ($companies[0] as $company) {
					$prj_cmpny=array(
						'prj_id' => $last_inserted_project_id,
						'cmpny_id' => $company
						);
					$project_model->insert_project_company($prj_cmpny);
				}

				$consultants = $this->request->getPost('assignConsultant'); // multiple select , secilen consultant'lar

				foreach ($consultants as $consultant) {
					$prj_cnsltnt=array(
						'prj_id' => $last_inserted_project_id,
						'cnsltnt_id' => $consultant,
						'active' => 1
						);
					$project_model->insert_project_consultant($prj_cnsltnt);
				}

				$contactuser= $this->request->getPost('assignContactPerson');
				$prj_cntct_prsnl=array(
					'prj_id' => $last_inserted_project_id,
					'usr_id' => $contactuser
				);

				$project_model->insert_project_contact_person($prj_cntct_prsnl);

				$session_array= array(
					'project_id' => $last_inserted_project_id,
					'project_name' => $project_model->get_project($last_inserted_project_id)
					);
				$this->session->set($session_array);

				return redirect()->to(site_url('project/'.$last_inserted_project_id));
			}
		}
		$data['validation']=$this->validator;

		echo view('template/header');
		echo view('project/create_project',$data);
		echo view('template/footer');
	}

	public function contact_person(){
		$cmpny_id=$this->input->post('company_id'); // 1,2,3 �eklinde company id ler al�nd�
		$user = array();
		if($cmpny_id != 'null'){
			$cmpny_id_arr = explode(",", $cmpny_id); // explode ile parse edildi. array icinde company id'ler tutuluyor.

			foreach ($cmpny_id_arr as $cmpny_id) {
				$user[] = $this->user_model->get_company_users($cmpny_id);
			}
			//foreach dongusu icinde tek tek company id'ler gonderilip ilgili user'lar bulunacak.
			//suanda sadece ilk company id ' yi al�p user lar� donuyor.
		}
		echo json_encode($user);
	}

	public function show_all_project(){
		$user_model = model(User_model::class);
		$project_model = model(Project_model::class);
		
		$data['projects'] = $project_model->get_projects();

		$kullaniciId = $this->session->id;
		if($kullaniciId!=null){
			$data['is_consultant'] = $user_model->is_user_consultant($kullaniciId);
			foreach ($data['projects'] as $key => $d) {
				$data['projects'][$key]['have_permission'] = $project_model->can_update_project_information($kullaniciId,$d['id']);
			}
		}
		else{
			$data['is_consultant'] = false;
			foreach ($data['projects'] as $key => $d) {
				$data['projects'][$key]['have_permission'] = false;
			}
		}

    //var_dump($data['projects']);
		echo view('template/header');
		echo view('project/show_all_project',$data);
		echo view('template/footer');
	}

	public function show_my_project(){
		$user_model = model(User_model::class);
		$project_model = model(Project_model::class);

		if($this->session->id!=null)
			$data['is_consultant'] = $user_model->is_user_consultant($this->session->id);
		else
			$data['is_consultant'] = false;

		$data['projects'] = $project_model->get_consultant_projects($this->session->id);
		echo view('template/header');
		echo view('project/show_my_project',$data);
		echo view('template/footer');
	}

	public function view_project($prj_id){
		$user_model = model(User_model::class);
		$project_model = model(Project_model::class);

		$userId = $this->session->id;
		$is_consultant_of_project = $user_model->is_consultant_of_project_by_user_id($userId,$prj_id);
		$is_contactperson_of_project = $user_model->is_contactperson_of_project_by_user_id($userId,$prj_id);

		if(!$is_consultant_of_project && !$is_contactperson_of_project){
			//Cillop gibi çalışan bir error kodu.
			//show_error('Sorry, you dont have permission to access this project information.');
			$this->session->set_flashdata('project_error', '<i class="fa fa-exclamation-circle"></i> Sorry, you dont have permission to access this project information.');
			redirect('projects','refresh');
		}

    	$data['prj_id'] = $prj_id;
		$data['projects'] = $project_model->get_project($prj_id);
		$data['status'] = $project_model->get_status($prj_id);
		$data['constant'] = $project_model->get_prj_consaltnt($prj_id);
		$data['companies'] = $project_model->get_prj_companies($prj_id);
		$data['contact'] = $project_model->get_prj_cntct_prsnl($prj_id);
		$data['allconsultants'] = $user_model->get_consultants();

		$data['is_consultant_of_project'] = $is_consultant_of_project;
		$data['is_contactperson_of_project'] = $is_contactperson_of_project;

		echo view('template/header');
		echo view('project/project_show_detailed',$data);
		echo view('template/footer');

	}


	public function update_project($prjct_id){

		$user_model = model(User_model::class);
		$project_model = model(Project_model::class);
		$company_model = model(Company_model::class);

		$userId = $this->session->id;

		if(!$user_model->is_consultant_of_project_by_user_id($userId,$prjct_id) and !$user_model->is_contactperson_of_project_by_user_id($userId,$prjct_id)){
			return redirect()->to(site_url('myprojects'));
		}

		$data['projects'] = $project_model->get_project($prjct_id);
		$data['companies'] = $company_model->get_companies();
		$data['consultants'] = $user_model->get_consultants();
		$data['project_status'] = $project_model->get_active_project_status();
		$data['assignedCompanies'] = $project_model->get_prj_companies($prjct_id);
		$data['assignedConsultant'] = $project_model->get_prj_consaltnt($prjct_id);
		$data['assignedContactperson'] = $project_model->get_prj_cntct_prsnl($prjct_id);

		//print_r($data['projects']);

		$companyIDs=array();
		foreach ($data['assignedCompanies'] as $key) { // bu k�s�mda sadece id lerden olusan array i al�yorum
			$companyIDs[] = $key['id'];
		}
		$data['companyIDs']=$companyIDs;

		$consultantIDs = array();
		foreach ($data['assignedConsultant'] as $key) { // bu k�s�mda sadece id lerden olusan array i al�yorum
			$consultantIDs[] = $key['id'];
		}
		$data['consultantIDs']=$consultantIDs;

		$contactIDs = array();
		foreach ($data['assignedContactperson'] as $key) { // bu k�s�mda sadece id lerden olusan array i al�yorum
			$contactIDs[] = $key['id'];
		}
		$data['contactIDs']=$contactIDs;

		foreach ($companyIDs as $cmpny_id) {
			$contactusers[]= $user_model->get_company_users($cmpny_id);
		}

		$data['contactusers']= $contactusers;

		if($this->input->post('projectName') != $data['projects']['name']) {
		   $is_unique =  '|is_unique[t_prj.name]';
		} else {
		   $is_unique =  '';
		}

		$this->form_validation->set_rules('projectName', 'Project Name', 'trim|required|max_length[200]|mb_strtolower|xss_clean'.$is_unique); // buraya isunique kontrolü
		$this->form_validation->set_rules('description', 'Description', 'trim|required|max_length[200]|xss_clean');
		$this->form_validation->set_rules('assignCompany','Assign Company','callback_check_default2');
		$this->form_validation->set_rules('assignConsultant','Assign Consultant','callback_check_default');
		$this->form_validation->set_rules('assignContactPerson','Assign Contact Person','required');

		//$this->form_validation->set_rules('surname', 'Password', 'required');
		//$this->form_validation->set_rules('email', 'Email' ,'trim|required|valid_email');
		if ($this->form_validation->run() !== FALSE)
		{

			date_default_timezone_set('UTC');

			$project = array(
			'name'=>$this->input->post('projectName'),
			'description'=>$this->input->post('description'),
			'start_date'=>date('Y-m-d', strtotime(str_replace('-', '/', $this->input->post('datepicker')))), // mysql icin formatını ayarladık
			'status_id'=>$this->input->post('status'),
			'active'=>1 //default active:1 olarak kaydediyoruz.
			);
			$this->project_model->update_project($project,$prjct_id);

			$companies = $_POST['assignCompany']; // multiple select , secilen company'ler

			$this->project_model->remove_company_from_project($prjct_id);	// once hepsini siliyoruz projeye ba�l� companylerin

			foreach ($companies as $company) {
				$prj_cmpny=array(
					'prj_id' => $prjct_id,
					'cmpny_id' => $company
					);
				$this->project_model->insert_project_company($prj_cmpny);
			}

			$consultants = $_POST['assignConsultant']; // multiple select , secilen consultant'lar

			$this->project_model->remove_consultant_from_project($prjct_id);

			foreach ($consultants as $consultant) {
				$prj_cnsltnt=array(
					'prj_id' => $prjct_id,
					'cnsltnt_id' => $consultant,
					'active' => 1
					);
				$this->project_model->insert_project_consultant($prj_cnsltnt);
			}

			$this->project_model->remove_contactuser_from_project($prjct_id);

			$contactuser= $this->input->post('assignContactPerson');
			$prj_cntct_prsnl=array(
				'prj_id' => $prjct_id,
				'usr_id' => $contactuser
			);

			$this->project_model->insert_project_contact_person($prj_cntct_prsnl);
			redirect('project/'.$prjct_id, 'refresh');
		}
		echo view('template/header');
		echo view('project/update_project',$data);
		echo view('template/footer');
	}

	function name_control(){
		$project_id = $this->uri->segment(2);
		$project_name = $this->input->post('projectName');
		if($this->project_model->have_project_name($project_id,$project_name))
			return true;
		else{
			$this->form_validation->set_message('name_control','Project name is required');
			return false;
		}
	}

	//delets project (if user has permission to edit/update project and is consultant)
	public function delete_project($project_id){
		$c_user = $this->user_model->get_session_user();
		if($this->project_model->can_update_project_information($c_user['id'], $project_id) == true && $this->user_model->is_user_consultant($c_user['id']) == true){
			$session->remove('project_id');
			$this->project_model->delete_project($project_id);
			redirect(base_url('myprojects'),'refresh');
		}else{
			redirect(base_url(''),'refresh');
		}	
	}

	public function addConsultantToProject($term){
		// check if user has a permission to edit company info
		$kullanici = $session->get('user_in');
		if(!$this->project_model->can_update_project_information($kullanici['id'],$term)){
			redirect(base_url(),'refresh');
		}

		$this->form_validation->set_rules('users','User','required|callback_check_consultant['.$term.']');
		if ($this->form_validation->run() !== FALSE)
		{	
			$prj_cnsltnt=array(
				'prj_id' => $term,
				'cnsltnt_id' => $this->input->post('users'),
				'active' => 1
				);
			$this->project_model->insert_project_consultant($prj_cnsltnt);
		}
		redirect('project/'.$term, 'refresh');
	}

	function check_consultant($str,$term) {
		return !$this->project_model->can_update_project_information($str,$term);
	}
	
}
?>
