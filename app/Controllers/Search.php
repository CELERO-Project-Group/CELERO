<?php

namespace App\Controllers;

class Search extends BaseController {

	public function search_pro($term = FALSE){
		$search_model = model(Search_model::class);

		if($term=="")
		{
			$term = $this->request->getPost('term');
			if(!empty($term))
				return redirect()->to(site_url('search/'.$term));
			else
				return redirect()->to(site_url(''));
		}

		$data['companies'] = $search_model->search_company($term);
		$data['projects'] = $search_model->search_project($term);

		echo view('template/header');
		echo view('search/index',$data);
		echo view('template/footer');
	}
}
?>