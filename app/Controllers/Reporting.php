<?php

namespace App\Controllers;

class Reporting extends BaseController{

	public function show_single($report_id){
		//reportidyi kullanarak otomatik link oluşturur. report/20 gibi.
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz. Diğer controllerlarda örnekler mevcuttur.
                $data['language'] = $session->get('site_lang');
		echo view('template/header');
		echo view('reporting/single',$data);
		echo view('template/footer');
	}

	public function show_all(){
                $loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $project_id = $session->get('project_id');
                //print_r($project_id);
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz.
                $data['userID'] = $session->get['user_in']['id']; 
                $data['userName'] = $session->get['user_in']['username'];
                $data['project_id'] = $session->get('project_id');
                $data['language'] = $session->get('site_lang');
		echo view('template/header_admin_test');
		echo view('admin/reportAllTest',$data);
		echo view('template/footer_admin');
	}
        
        public function create(){
		//burada php kodu kullanabilirsiniz. data arrayinin içini doldurabilirsiniz.
		$loginData = $session->get('user_in');
		if(empty($loginData)){
			return redirect()->to(site_url('login'));
		}
                $data['userID'] = $session->get['user_in']['id'];
                $data['userName'] = $session->get['user_in']['username'];
                $data['language'] = $session->get('site_lang');
		echo view('template/header_admin_test');
		echo view('admin/reportTest',$data); 
		echo view('template/footer_admin');
	}
}
?>
