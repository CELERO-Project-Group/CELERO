//TODO: naming of this file should be Map. 

<?php

namespace App\Controllers;

class Map extends BaseController {

	public function index(){  
        //print_r($this->session->get_userdata('language'));
        //print_r($session->get['user_in']);
        if(isset($session->get['user_in'])) {
            if(empty($session->get['user_in'])){
                return redirect()->to(site_url('login'));
            } 
        } else {
            return redirect()->to(site_url('login'));
        }
        
        if(isset($session->get['project_id'])) {
            if($session->get['project_id']==null || $session->get['project_id']==''){
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }
        
        $data['site_lang'] = 'english';
    
        $data['project_id'] = $session->get['project_id'];
        $data['projects'] = $project_model->get_project($session->get['project_id']);
        $data['language'] = $session->get('site_lang');


        echo view('template/header_map');
        echo view('map/index',$data);
        echo view('template/footer_map');
	}
        
    public function mapHeader(){   
        //print_r($session->get['user_in']);
        if(isset($session->get['user_in'])) {
            if(empty($session->get['user_in'])){
                return redirect()->to(site_url('login'));
            } 
        } else {
            return redirect()->to(site_url('login'));
        }
        echo view('map/mapHeader');           
	}

	
        
      
}