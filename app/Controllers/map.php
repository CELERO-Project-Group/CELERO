//TODO: naming of this file should be Map. 

<?php

namespace App\Controllers;

class Map extends BaseController {

	function __construct(){
		parent::__construct();
                $this->load->model('project_model');
	}

	public function index(){  
            //print_r($this->session->get_userdata('language'));
            //print_r($session->get['user_in']);
            if(isset($session->get['user_in'])) {
               if(empty($session->get['user_in'])){
			redirect(base_url('login'),'refresh');
		} 
            } else {
                redirect(base_url('login'),'refresh');
            }
            
            if(isset($session->get['project_id'])) {
                if($session->get['project_id']==null || $session->get['project_id']==''){
                    redirect(base_url('projects'), 'refresh');
                }
            } else {
                redirect(base_url('projects'), 'refresh');
            }
            
            if(isset($this->session->get_userdata('language'))) {
               if(empty($this->session->get_userdata('language'))==null){
			$data['site_lang'] = 'english';
		} else {
                    if($this->session->get_userdata('language')=='english')  $data['site_lang'] = 'english';
                    if($this->session->get_userdata('language')=='turkish')  $data['site_lang'] = 'turkish';
                } 
            } else {
                $data['site_lang'] = 'english';
            }  
             $data['project_id'] = $session->get['project_id'];
             $data['projects'] = $this->project_model->get_project($session->get['project_id']);
             $data['language'] = $session->get('site_lang');
             //print_r($data['projects']);
            /*if(isset($session->get['project_id'])) {
                if($session->get['project_id']==null || $session->get['project_id']==''){
                    redirect(base_url('projects'), 'refresh');
                }
            } else {
                redirect(base_url('projects'), 'refresh');
            }*/
            
            /*if(isset($session->get['user_in']['role_id'])) {
                if(($session->get['user_in']['role_id']==null || $session->get['user_in']['role_id']=='')
                         || $session->get['user_in']['role_id']!=1){
                       redirect(base_url('company'), 'refresh');
		}
            } else {
                //redirect(base_url('company'), 'refresh');
            }*/

            $this->load->view('template/header_map');
            $this->load->view('map/index',$data);
            $this->load->view('template/footer_map');
	}
        
        public function mapHeader(){   
            //print_r($session->get['user_in']);
            if(isset($session->get['user_in'])) {
               if(empty($session->get['user_in'])){
			redirect(base_url('login'),'refresh');
				} 
            } else {
                redirect(base_url('login'),'refresh');
            }
                
            /*if(isset($session->get['project_id'])) {
                if($session->get['project_id']==null || $session->get['project_id']==''){
                    redirect(base_url('projects'), 'refresh');
                }
            } else {
                redirect(base_url('projects'), 'refresh');
            }*/
            
            /*if(isset($session->get['user_in']['role_id'])) {
                if(($session->get['user_in']['role_id']==null || $session->get['user_in']['role_id']=='')
                         || $session->get['user_in']['role_id']!=1){
                       redirect(base_url('company'), 'refresh');
				}
            } else {
                //redirect(base_url('company'), 'refresh');
            }*/

            $this->load->view('map/mapHeader');
           
	}

	
        
      
}