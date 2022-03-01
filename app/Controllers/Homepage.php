<?php

namespace App\Controllers;

class Homepage extends BaseController {

	public function index(){
		//phpinfo();
		$session = \Config\Services::session();

		echo view('template/header');
		echo view('homepage/index');
		echo view('template/footer');
	}
}