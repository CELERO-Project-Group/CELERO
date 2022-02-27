<?php

namespace App\Controllers;

class Homepage extends BaseController {

	function __construct(){
		parent::__construct();
				$this->config->set_item('language', $session->get('site_lang'));

	}

	public function index(){
		//phpinfo();
		$this->load->view('template/header');
		$this->load->view('homepage/index');
		$this->load->view('template/footer');
	}
}