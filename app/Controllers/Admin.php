<?php

namespace App\Controllers;

class Admin extends BaseController {

	function __construct(){
		parent::__construct();
	}

	public function index(){
		$this->load->view('template/header_admin');
		$this->load->view('isscoping/index');
		$this->load->view('template/footer_admin');
	}
        
        public function report(){  
            //print_r($this->session->userdata['user_in']['id']);
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userID'] = $this->session->userdata['user_in']['id'];
                $data['userName'] = $this->session->userdata['user_in']['username'];
		$this->load->view('template/header_admin');
		$this->load->view('admin/report',$data); 
		$this->load->view('template/footer_admin');
	}
       
        public function reportTest(){  
            //print_r($this->session->userdata['user_in']['id']);
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userID'] = $this->session->userdata['user_in']['id'];
                $data['userName'] = $this->session->userdata['user_in']['username'];
		$this->load->view('template/header_admin_test');
		$this->load->view('admin/reportTest',$data); 
		$this->load->view('template/footer_admin');
	}

	public function newFlow(){
                //print_r($this->session->userdata['user_in']);
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userName'] = $this->session->userdata['user_in']['username'];
		$this->load->view('template/header_admin');
		$this->load->view('admin/newFlow',$data);    
		$this->load->view('template/footer_admin');
	}
        
        public function newEquipment(){  
            //print_r($this->session->userdata['user_in']['id']);
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userName'] = $this->session->userdata['user_in']['username'];
		$this->load->view('template/header_admin');
		$this->load->view('admin/newEquipment',$data); 
		$this->load->view('template/footer_admin');
	}
        
        public function newProcess(){  
            //print_r($this->session->userdata['user_in']['id']);
                $loginData = $this->session->userdata('user_in');
		if(empty($loginData)){
			redirect(base_url('login'),'refresh');
		}
                $data['userName'] = $this->session->userdata['user_in']['username'];
		$this->load->view('template/header_admin');
		$this->load->view('admin/newProcess',$data); 
		$this->load->view('template/footer_admin');
	}
        
        public function tooltip(){
		//$this->load->view('template/header');
		$this->load->view('isscoping/tooltip');
		//$this->load->view('template/footer');
	}
        
         public function tooltipscenarios(){
		//$this->load->view('template/header');
		$this->load->view('isscoping/tooltipscenarios');
		//$this->load->view('template/footer');
	}
        
        
        
        
        
        
         
        public function clusters() {
           $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/clusters',$data); 
            $this->load->view('template/footer_admin'); 
        }
        
        public function industrialZones() {
           $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/industrialZones',$data); 
            $this->load->view('template/footer_admin'); 
        }
        
        public function reports() {
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/reports',$data); 
            $this->load->view('template/footer_admin'); 
        }
        
        public function consultants() {
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/consultants',$data); 
            $this->load->view('template/footer_admin'); 
        }
        
        public function employees() {  
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/employees',$data); 
            $this->load->view('template/footer_admin'); 
        }
        
        public function rpEmployeesList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpEmployeesList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
         public function rpCompaniesInfoList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesInfoList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProjectsList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesProjectsList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProjectDetailsList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesProjectDetailsList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesNotInClustersList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesNotInClustersList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesWasteEmissionList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesWasteEmissionList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProductionList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesProductionList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProcessesList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesProcessesList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpConsultantsList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpConsultantsList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesInClustersList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpCompaniesInClustersList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function rpEquipmentList() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/rpEquipmentList',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        
        public function zoneEmployees() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/zoneEmployees',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        public function zoneCompanies() { 
            $loginData = $this->session->userdata('user_in');
            if(empty($loginData)){
                    redirect(base_url('login'),'refresh');
            }
            $data['userID'] = $this->session->userdata['user_in']['id'];
            $data['userName'] = $this->session->userdata['user_in']['username'];
            $this->load->view('template/header_admin'); 
            $this->load->view('admin/zoneCompanies',$data); 
            $this->load->view('template/footer_admin'); 
        
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

}

