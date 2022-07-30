<?php

namespace App\Controllers;

class Ecotracking extends BaseController {

	public function save($company_id,$machine_id,$powera,$powerb,$powerc){
		$ecotracking_model = model(Ecotracking_model::class);
		$ecotracking_model->save($company_id,$machine_id,$powera,$powerb,$powerc);
		redirect('ecotracking/'.$company_id.'/'.$machine_id);
	}

	public function show($company_id,$machine_id){
		$ecotracking_model = model(Ecotracking_model::class);

		$data['veriler'] = $ecotracking_model->get($company_id,$machine_id);
		$data['company_id']=$company_id;
		echo view('template/header');
		echo view('ecotracking/show',$data);
		echo view('template/footer');
	}

	public function index(){
		$equipment_model = model(Equipment_model::class);
		$company_model = model(Company_model::class);

		$data['companies'] = $company_model->get_project_companies(session()->project_id);
		foreach ($data['companies'] as $company) {
			$data['informations'][] = $equipment_model->all_information_of_equipment($company['id']);
		}
		echo view('template/header');
		echo view('ecotracking/index',$data);
		echo view('template/footer');
	}

	public function json($company_id,$machine_id){
		$ecotracking_model = model(Ecotracking_model::class);

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
