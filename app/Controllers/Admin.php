<?php

namespace App\Controllers;

class Admin extends BaseController {

	public function index(){
		echo view('template/header_admin');
		echo view('isscoping/index');
		echo view('template/footer_admin');
	}
        
        public function report(){  
            //print_r($session->get['user_in']['id']);
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userID'] = $session->get['user_in']['id'];
                $data['userName'] = $session->get['user_in']['username'];
		echo view('template/header_admin');
		echo view('admin/report',$data); 
		echo view('template/footer_admin');
	}
       
        public function reportTest(){  
            //print_r($session->get['user_in']['id']);
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userID'] = $session->get['user_in']['id'];
                $data['userName'] = $session->get['user_in']['username'];
		echo view('template/header_admin_test');
		echo view('admin/reportTest',$data); 
		echo view('template/footer_admin');
	}

	public function newFlow(){
                //print_r($session->get['user_in']);
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userName'] = $session->get['user_in']['username'];
		echo view('template/header_admin');
		echo view('admin/newFlow',$data);    
		echo view('template/footer_admin');
	}
        
        public function newEquipment(){  
            //print_r($session->get['user_in']['id']);
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userName'] = $session->get['user_in']['username'];
		echo view('template/header_admin');
		echo view('admin/newEquipment',$data); 
		echo view('template/footer_admin');
	}
        
        public function newProcess(){  
            //print_r($session->get['user_in']['id']);
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userName'] = $session->get['user_in']['username'];
		echo view('template/header_admin');
		echo view('admin/newProcess',$data); 
		echo view('template/footer_admin');
	}
        
        public function tooltip(){
		//echo view('template/header');
		echo view('isscoping/tooltip');
		//echo view('template/footer');
	}
        
         public function tooltipscenarios(){
		//echo view('template/header');
		echo view('isscoping/tooltipscenarios');
		//echo view('template/footer');
	}
         
        public function clusters() {
           $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/clusters',$data); 
            echo view('template/footer_admin'); 
        }
        
        public function industrialZones() {
           $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/industrialZones',$data); 
            echo view('template/footer_admin'); 
        }
        
        public function reports() {
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/reports',$data); 
            echo view('template/footer_admin'); 
        }
        
        public function consultants() {
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/consultants',$data); 
            echo view('template/footer_admin'); 
        }
        
        public function employees() {  
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/employees',$data); 
            echo view('template/footer_admin'); 
        }
        
        public function rpEmployeesList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpEmployeesList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
         public function rpCompaniesInfoList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesInfoList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProjectsList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesProjectsList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProjectDetailsList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesProjectDetailsList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesNotInClustersList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesNotInClustersList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesWasteEmissionList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesWasteEmissionList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProductionList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesProductionList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesProcessesList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesProcessesList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpConsultantsList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpConsultantsList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpCompaniesInClustersList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpCompaniesInClustersList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function rpEquipmentList() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/rpEquipmentList',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        
        public function zoneEmployees() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/zoneEmployees',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        public function zoneCompanies() { 
            $loginData = $session->get('user_in');
            if(empty($loginData)){
                    return redirect()->to(site_url('login'));
            }
            $data['userID'] = $session->get['user_in']['id'];
            $data['userName'] = $session->get['user_in']['username'];
            echo view('template/header_admin'); 
            echo view('admin/zoneCompanies',$data); 
            echo view('template/footer_admin'); 
        
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

}

