<?php

namespace App\Controllers;

class Homepage extends BaseController {

	public function index(){
		// TODO: we need to find a better way.
		$data['username'] =  $this->session->username;
		$data['role_id'] =  $this->session->role_id;
		//phpinfo();
		echo view('template/header',$data);
		echo view('homepage/index',$data);
		echo view('template/footer');
	}
}