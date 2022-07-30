<?php

namespace App\Controllers;

class Cluster extends BaseController{

	public function cluster_to_match_company(){

		$this->form_validation->set_rules('company','Company Field','required');
		$this->form_validation->set_rules('cluster','Cluster Field','required');

		if ($this->form_validation->run() !== FALSE)
		{
			$company_id = $this->input->post('company');
			$cluster_id = $this->input->post('cluster');
			if($cluster_model->can_write_info($cluster_id,$company_id) == true){
				$cmpny_clstr = array(
						'cmpny_id' => $company_id,
						'clstr_id' => $cluster_id
					);
				$cluster_model->set_cmpny_clstr($cmpny_clstr);
			}
		}

		$data['clusters'] = $cluster_model->get_clusters();
		$data['companies'] = $company_model->get_companies();

		echo view('template/header');
		echo view('cluster/cluster_match_company',$data);
		echo view('template/footer');
	}
}
?>
