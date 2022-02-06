<?php

namespace App\Controllers;

class Search extends BaseController {

	function __construct(){
		parent::__construct();
		$this->load->model('search_model','',TRUE);
				$this->config->set_item('language', $this->session->userdata('site_lang'));

	}

	public function search_pro($term = FALSE){
		if($term=="")
		{
			$term = $this->input->post('term');
			if(!empty($term))
				redirect(base_url('search/'.$term), 'refresh');
			else
				redirect(base_url('','refresh'));
		}

		$data['companies'] = $this->search_model->search_company($term);
		$data['projects'] = $this->search_model->search_project($term);

		$this->load->view('template/header');
		$this->load->view('search/index',$data);
		$this->load->view('template/footer');
	}
}
?>