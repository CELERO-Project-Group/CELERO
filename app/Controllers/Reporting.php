<?php

namespace App\Controllers;

class Reporting extends BaseController{

	function __construct(){
		parent::__construct();
		$this->load->model('company_model');
		$this->load->library('form_validation');
		$this->config->set_item('language', $this->session->userdata('site_lang'));
	}

	public function show_single($report_id){
		//reportidyi kullanarak otomatik link oluşturur. report/20 gibi.
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz. Diğer controllerlarda örnekler mevcuttur.
                $data['language'] = $this->session->userdata('site_lang');
		$this->load->view('template/header');
		$this->load->view('reporting/single',$data);
		$this->load->view('template/footer');
	}

	public function show_all(){
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $project_id = $this->session->userdata('project_id');
                //print_r($project_id);
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz.
                $data['userID'] = $this->session->userdata['user_in']['id']; 
                $data['userName'] = $this->session->userdata['user_in']['username'];
                $data['project_id'] = $this->session->userdata('project_id');
                $data['language'] = $this->session->userdata('site_lang');
		$this->load->view('template/header_admin_test');
		$this->load->view('admin/reportAllTest',$data);
		$this->load->view('template/footer_admin');
	}
        
        public function create(){
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz.
		$loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userID'] = $this->session->userdata['user_in']['id'];
                $data['userName'] = $this->session->userdata['user_in']['username'];
                $data['language'] = $this->session->userdata('site_lang');
		$this->load->view('template/header_admin_test');
		$this->load->view('admin/reportTest',$data); 
		$this->load->view('template/footer_admin');
	}
}
?>
