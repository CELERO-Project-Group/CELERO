<?php

namespace App\Controllers;

class Ecotracking extends BaseController {

	function __construct(){
		parent::__construct();
		$this->load->model('ecotracking_model');
		$this->load->model('company_model');
		$this->load->model('equipment_model');
		$this->config->set_item('language', $session->get('site_lang'));
	}

	public function save($company_id,$machine_id,$powera,$powerb,$powerc){
		$this->ecotracking_model->save($company_id,$machine_id,$powera,$powerb,$powerc);
		redirect('ecotracking/'.$company_id.'/'.$machine_id);
	}

	public function show($company_id,$machine_id){
		$data['veriler'] = $ecotracking_model->get($company_id,$machine_id);
		$data['company_id']=$company_id;
		echo view('template/header');
		echo view('ecotracking/show',$data);
		echo view('template/footer');
	}

	public function index(){
		$project_id = $session->get('project_id');
		$data['companies'] = $company_model->get_project_companies($project_id);
		//print_r($data['companies']);
		foreach ($data['companies'] as $company) {
			//echo $company['id'];
			$data['informations'][] = $equipment_model->all_information_of_equipment($company['id']);
		}
		//print_r($data['informations']);
		echo view('template/header');
		echo view('ecotracking/index',$data);
		echo view('template/footer');
	}

	public function json($company_id,$machine_id){
		header("Content-Type: application/json", true);
		/* Return JSON */
		$data['veriler'] = $ecotracking_model->get($company_id,$machine_id);
		//print_r($data);

		$numItems = count($data['veriler']);
		$i = 0;
		$defer="[";
		foreach ($data['veriler'] as $d) {
			$date1000=strtotime($d['date'])*1000;
			if(++$i === $numItems) {
				$defer.="[".$date1000.",".$d['powera']."]";
			}else{
			$defer.="[".$date1000.",".$d['powera']."],";
			}
		}
		$defer.="]";

		echo $defer;
	}

	
}
?>
