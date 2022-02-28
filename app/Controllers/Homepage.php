<?php

namespace App\Controllers;

class Homepage extends BaseController {

	public function index(){
		//phpinfo();
		echo view('template/header');
		echo view('homepage/index');
		echo view('template/footer');
	}
}