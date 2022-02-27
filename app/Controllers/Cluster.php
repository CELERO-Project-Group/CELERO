<?php

namespace App\Controllers;

class Cluster extends BaseController{

	function __construct(){
		parent::__construct();
		$this->load->model('cluster_model');
		$this->load->model('company_model');
		$this->load->library('form_validation');
				$this->config->set_item('language', $session->get('site_lang'));

	}

	public function cluster_to_match_company(){

		$this->form_validation->set_rules('company','Company Field','required');
		$this->form_validation->set_rules('cluster','Cluster Field','required');

		if ($this->form_validation->run() !== FALSE)
		{
			$company_id = $this->input->post('company');
			$cluster_id = $this->input->post('cluster');
			if($this->cluster_model->can_write_info($cluster_id,$company_id) == true){
				$cmpny_clstr = array(
						'cmpny_id' => $company_id,
						'clstr_id' => $cluster_id
					);
				$this->cluster_model->set_cmpny_clstr($cmpny_clstr);
			}
		}

		$data['clusters'] = $this->cluster_model->get_clusters();
		$data['companies'] = $this->company_model->get_companies();

		$this->load->view('template/header');
		$this->load->view('cluster/cluster_match_company',$data);
		$this->load->view('template/footer');
	}
}
?>
