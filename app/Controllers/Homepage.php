<?php

namespace App\Controllers;

class Homepage extends BaseController {

	public function index(){
		
		// TODO: we need to find a better way.
		$data['username'] =  $this->session->username;
		 
		//phpinfo();
		echo view('template/header');
		echo view('homepage/index',$data);
		echo view('template/footer');
	}
}