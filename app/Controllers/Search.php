<?php

namespace App\Controllers;

class Search extends BaseController {

	public function search_pro($term = FALSE){
		if($term=="")
		{
			$term = $this->input->post('term');
			if(!empty($term))
				redirect(base_url('search/'.$term), 'refresh');
			else
				redirect(base_url('','refresh'));
		}

		$data['companies'] = $search_model->search_company($term);
		$data['projects'] = $search_model->search_project($term);

		echo view('template/header');
		echo view('search/index',$data);
		echo view('template/footer');
	}
}
?>