<?php

namespace App\Controllers;
use App\Models\User_model;
use App\Models\Project_model;
use App\Models\Cpscoping_model;
use App\Models\Product_model;
use App\Models\Flow_model;
use App\Models\Process_model;
use App\Models\Company_model;

class Cpscoping extends BaseController {
	
	public function index(){
		$project_model = model(Project_model::class);
		$user_model = model(User_model::class);
		$cpscoping_model = model(Cpscoping_model::class);

		$c_user = $user_model->get_session_user();
		if($cpscoping_model->can_consultant_prjct($c_user['id']) == false){
			return redirect()->back();
		}else{
			$data['c_projects']=$user_model->get_consultant_projects_from_userid($c_user['id']);
			$result = array(array());
			$com_array = array();
			$i = 0;
			//foreach ($data['c_projects'] as $project_name) {
				$com_array = $project_model->get_prj_companies(session()->project_id);
				foreach ($com_array as $c) {
					$com_pro = array(
						"project_name" => session()->project_name,
						"company_name" => $c['name'],
						"project_id" => session()->project_id,
						"company_id" => $c['id']
					);
					$result[$i] = $com_pro;
					$i++;
				}
			//}
			$deneme = array(array());
			$j = 0;
			foreach ($result as $r) {
				$flow_prcss = $cpscoping_model->get_allocation_values($r['company_id'],session()->project_id);
				$deneme[$j] = $flow_prcss;
				$j++;
			}
			$data['flow_prcss'] = $deneme;
			$data['com_pro'] = $result;
			echo view('template/header');
			echo view('cpscoping/index',$data);
			echo view('template/footer');
		}
	}

// 	//Getting project companies from ajax
	public function p_companies($pid){
		$project_model = model(Project_model::class);
		$com_array = $project_model->get_prj_companies($pid);
		header("Content-Type: application/json", true);
		/* Return JSON */
		echo json_encode($com_array);
	}

	public function checkbox_control($str){
		if($str == 0){
			$this->form_validation->set_message('checkbox_control', 'The %s field is required.');
			return FALSE;
		}else{
			return TRUE;
		}
	}

// 	public function cp_allocation($project_id,$company_id){

// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$product_model = model(Product_model::class);
// 		$flow_model = model(Flow_model::class);
// 		$process_model = model(Process_model::class);	

// 		if (!empty($this->request->getPost())){
// 			if ($this->validate([
// 				'prcss_name'=> 'required|trim',
// 				'flow_name'=> 'required|trim',
// 				'flow_type_name'=> 'required|trim',
// 				'amount'=> 'required|trim',
// 				'allocation_amount'=>  'required|trim|max_length[7]|greater_than[0]',
// 				'error_amount'=> 'required|trim|integer|max_length[3]|greater_than[0]',
// 				'unit_amount'=> 'required|trim',
// 				'cost'=> 'required|trim',
// 				'allocation_cost'=>  'required|trim|max_length[7]|greater_than[0]',
// 				'error_cost'=>  'required|trim|integer|max_length[3]|greater_than[0]',
// 				'unit_cost'=>  'required|trim',
// 				'env_impact'=>  'required|trim|max_length[25]',
// 				'allocation_env_impact'=>  'required|trim|max_length[7]|greater_than[0]',
// 				'error_ep'=>  'required|trim|integer|max_length[3]|greater_than[0]',
// 				'unit_env_impact'=>  'required|trim',
// 				'reference'=>  'required|trim',
// 				'unit_reference'=>  'required|trim',
// 				'nameofref'=>  'trim|required',
// 				'kpi'=>  'required|trim',
// 				'unit_kpi'=>  'required|trim',
// 				'kpidef'=>  'trim'
// 			])){

// 			$prcss_name = $this->request->getPost('prcss_name');
// 			$flow_name = $this->request->getPost('flow_name');
// 			$flow_type_name = $this->request->getPost('flow_type_name');
// 			$amount = $this->request->getPost('amount');
// 			$allocation_amount = $this->request->getPost('allocation_amount');
// 			$importance_amount = $this->request->getPost('error_amount');
// 			$cost = $this->request->getPost('cost');
// 			$allocation_cost = $this->request->getPost('allocation_cost');
// 			$importance_cost = $this->request->getPost('error_cost');
// 			$env_impact = $this->request->getPost('env_impact');
// 			$allocation_env_impact = $this->request->getPost('allocation_env_impact');
// 			$importance_env_impact = $this->request->getPost('error_ep');
// 			$unit_amount = $this->request->getPost('unit_amount');
// 			$unit_cost = $this->request->getPost('unit_cost');
// 			$unit_env_impact = $this->request->getPost('unit_env_impact');
// 			$reference = $this->request->getPost('reference');
// 			$unit_reference = $this->request->getPost('unit_reference');
// 			$kpi = $this->request->getPost('kpi');
// 			$unit_kpi = $this->request->getPost('unit_kpi');
// 			$kpidef = $this->request->getPost('kpidef');
// 			$nameofref = $this->request->getPost('nameofref');
// 			//$kpi_error = $this->request->getPost('kpi_error');

// 			$array_allocation = array(
// 				'prcss_id'=>$prcss_name,
// 				'flow_id'=>$flow_name,
// 				'flow_type_id'=>$flow_type_name,
// 				'amount'=>$amount,
// 				'unit_amount'=>$unit_amount,
// 				'allocation_amount'=>$allocation_amount,
// 				'error_amount'=>$importance_amount,
// 				'cost'=>$cost,
// 				'unit_cost'=>$unit_cost,
// 				'allocation_cost'=>$allocation_cost,
// 				'error_cost'=>$importance_cost,
// 				'env_impact'=>$env_impact,
// 				'unit_env_impact'=>$unit_env_impact,
// 				'allocation_env_impact'=>$allocation_env_impact,
// 				'error_ep'=>$importance_env_impact,
// 				'reference' => $reference,
// 				'unit_reference' => $unit_reference,
// 				'kpi' => $kpi,
// 				'unit_kpi' => $unit_kpi,
// 				'kpidef' => $kpidef,
// 				'nameofref' => $nameofref
// 			);
// 			$insertID = $cpscoping_model->set_cp_allocation($array_allocation);
// 			$allocation_array = array(
// 				'allocation_id' => $insertID,
// 				'prjct_id' => $project_id,
// 				'cmpny_id' => $company_id
// 			);
// 			$cpscoping_model->set_cp_allocation_main($allocation_array);
// 			return redirect()->to('cpscoping/'.$project_id.'/'.$company_id.'/show');
// 			}
// 		}
// 		$data['project_id'] = $project_id;
// 		$data['company_id'] = $company_id;
// 		$data['product'] = $product_model->get_product_list($company_id);
// 		$data['company_flows']=$flow_model->get_company_flow_list($company_id);
// 		$data['prcss_info'] = $process_model->get_cmpny_flow_prcss($company_id);
// 		$data['unit_list'] = $flow_model->get_unit_list();

// 		$array_temp = array();
// 		$temp_index = 0;
// 		$kontrol = array();
// 		$index = 0;
// 		foreach ($data['prcss_info'] as $prcss_info) {
// 			$deneme = 0;
// 			$kontrol[$index] = $prcss_info['prcessname'];
// 			$index++;
// 			for($k = 0 ; $k < $index - 1 ; $k++){
// 				if($kontrol[$k] == $prcss_info['prcessname']){
// 					$deneme = 1;
// 				}
// 			}
// 			if($deneme == 0){
// 				$array_temp[$temp_index] = $prcss_info;
// 				$temp_index++;
// 			}
// 		}
// 		$data['validation'] = $this->validator;
// 		$data['prcss_info'] = $array_temp;
 
// 		echo view('template/header');
// 		echo view('cpscoping/allocation',$data);
// 		echo view('template/footer');
// 	}

	public function allocationlist($project_id,$company_id){
		$cpscoping_model = model(Cpscoping_model::class);
		$company_model = model(Company_model::class);
		$data['allocationlar'] = $cpscoping_model->get_allocation_values($company_id,$project_id);
		$data['companyID'] = $company_id;
		$data['company_info'] = $company_model->get_company($company_id);
		$data['validation'] = $this->validator;

		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/allocationlist',$data);
		echo view('template/footer');
	}

	
	
// 	public function cp_show_allocation($project_id,$company_id){
// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$allocation_id_array = $cpscoping_model->get_allocation_id_from_ids($company_id,$project_id);
// 		$data['allocation'] = array();
// 		$data['allocation_output'] = array();
// 		foreach ($allocation_id_array as $ids) {

// 			$ilkveri = $cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);			
// 			if($ilkveri['prcss_id']!='0'){
// 				$prcss_name = $ilkveri['flow_id'].'-'.$ilkveri['prcss_id'].'-'.$ilkveri['flow_type_id'];
// 				$data['allocationveri'][$prcss_name] = $ilkveri;
// 				$prcss_total = $ilkveri['flow_id'].'-0-'.$ilkveri['flow_type_id'];
// 				if(!isset($data['allocationveri'][$prcss_total]['amount'])){
// 					$data['allocationveri'][$prcss_total]['amount'] = '0';
// 					$data['allocationveri'][$prcss_total]['unit_amount'] = '';
// 					$data['allocationveri'][$prcss_total]['cost'] = '0';
// 					$data['allocationveri'][$prcss_total]['unit_cost'] = '';
// 					$data['allocationveri'][$prcss_total]['env_impact'] = '0';
// 					$data['allocationveri'][$prcss_total]['unit_env_impact'] = '';
// 				}
// 				$data['allocationveri'][$prcss_total]['amount'] += $ilkveri['amount'];
// 				$data['allocationveri'][$prcss_total]['unit_amount'] = $ilkveri['unit_amount'];
// 				$data['allocationveri'][$prcss_total]['cost'] += $ilkveri['cost'];
// 				$data['allocationveri'][$prcss_total]['unit_cost'] = $ilkveri['unit_cost'];
// 				$data['allocationveri'][$prcss_total]['env_impact'] += $ilkveri['env_impact'];
// 				$data['allocationveri'][$prcss_total]['unit_env_impact'] = 'EP';
// 			}

// 			$data['allocation'][] = $cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);		
// 			$data['allocation_output'][] = $cpscoping_model->get_allocation_from_allocation_id_output($ids['allocation_id']);

// 			$data['active'][$ids['allocation_id']] = $cpscoping_model->get_is_candidate_active_position($ids['allocation_id']);

// 		}
// 		//print_r($data);
// 		echo view('template/header');
// 		echo view('cpscoping/show',$data);
// 		echo view('template/footer');
// 	}

// 	// Edit allocation function
	public function edit_allocation($allocation_id){
		$user_model = model(User_model::class);
		$flow_model = model(Flow_model::class);

		$cpscoping_model = model(Cpscoping_model::class);
		$data['unit_list'] = $flow_model->get_unit_list();
		$data['allocation'] = $cpscoping_model->get_allocation_from_allocation_id($allocation_id);
		// check if allocation is not set or deleted
		if(empty($data['allocation'])) { redirect(site_url()); }
		//check if user has permission to edit
		$userId = $this->session->id;
		$permission= $user_model->can_edit_company($userId,$data['allocation']['cmpny_id']);
		if($permission==FALSE){redirect(site_url());}


		if (!empty($this->request->getPost())){
			if ($this->validate([
				'prcss_name'=> 'required|trim',
				'flow_name'=> 'required|trim',
				'flow_type_name'=> 'required|trim',
				'amount'=> 'required|trim',
				'allocation_amount'=>  'required|trim|max_length[7]|greater_than[0]',
				'error_amount'=> 'required|trim|integer|max_length[3]|greater_than[0]',
				'unit_amount'=> 'required|trim',
				'cost'=> 'required|trim',
				'allocation_cost'=>  'required|trim|max_length[7]|greater_than[0]',
				'error_cost'=>  'required|trim|integer|max_length[3]|greater_than[0]',
				'unit_cost'=>  'required|trim',
				'env_impact'=>  'required|trim|max_length[25]',
				'allocation_env_impact'=>  'required|trim|max_length[7]|greater_than[0]',
				'error_ep'=>  'required|trim|integer|max_length[3]|greater_than[0]',
				'unit_env_impact'=>  'required|trim',
				'reference'=>  'required|trim',
				'unit_reference'=>  'required|trim',
				'nameofref'=>  'trim|required',
				'kpi'=>  'required|trim',
				'unit_kpi'=>  'required|trim',
				'kpidef'=>  'trim'
			])){

			$amount = $this->request->getPost('amount');
			$allocation_amount = $this->request->getPost('allocation_amount');
			$importance_amount = $this->request->getPost('error_amount');
			$cost = $this->request->getPost('cost');
			$allocation_cost = $this->request->getPost('allocation_cost');
			$importance_cost = $this->request->getPost('error_cost');
			$env_impact = $this->request->getPost('env_impact');
			$allocation_env_impact = $this->request->getPost('allocation_env_impact');
			$importance_env_impact = $this->request->getPost('error_ep');
			$unit_amount = $this->request->getPost('unit_amount');
			$unit_cost = $this->request->getPost('unit_cost');
			$unit_env_impact = $this->request->getPost('unit_env_impact');
			$reference = $this->request->getPost('reference');
			$unit_reference = $this->request->getPost('unit_reference');
			$kpi = $this->request->getPost('kpi');
			$unit_kpi = $this->request->getPost('unit_kpi');
			$nameofref = $this->request->getPost('nameofref');
			$kpidef = $this->request->getPost('kpidef');
			//$kpi_error = $this->request->getPost('kpi_error');

			$array_allocation = array(
				'amount'=>$amount,
				'unit_amount'=>$unit_amount,
				'allocation_amount'=>$allocation_amount,
				'error_amount'=>$importance_amount,
				'cost'=>$cost,
				'unit_cost'=>$unit_cost,
				'allocation_cost'=>$allocation_cost,
				'error_cost'=>$importance_cost,
				'env_impact'=>$env_impact,
				'unit_env_impact'=>$unit_env_impact,
				'allocation_env_impact'=>$allocation_env_impact,
				'error_ep'=>$importance_env_impact,
				'reference' => $reference,
				'unit_reference' => $unit_reference,
				'kpi' => $kpi,
				'kpidef' => $kpidef,
				'nameofref' => $nameofref,
				'unit_kpi' => $unit_kpi
			);
			$cpscoping_model->update_cp_allocation($array_allocation,$allocation_id);

			redirect('cpscoping');
			}
		}
		$data['validation'] = $this->validator;

		echo view('template/header');
		echo view('cpscoping/edit_allocation',$data);
		echo view('template/footer');
	}

	public function kpi_calculation_chart($prjct_id,$cmpny_id){
		$cpscoping_model = model(Cpscoping_model::class);
		$allocation_id_array = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		$data['allocation'] = array();
		foreach ($allocation_id_array as $ids) {
			if(!empty($ids['allocation_id'])){
				$veri = $cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
				if(!empty($veri['allocation_id'])){
					$data['allocation'][] = $veri;
				}
			}
		}
		header("Content-Type: application/json", true);
		echo json_encode($data);
	}

	public function get_already_allocated_allocation_except_given($flow_id,$flow_type_id,$cmpny_id,$process_id,$prjct_id){
		$cpscoping_model = model(Cpscoping_model::class);
		$array = $cpscoping_model->get_process_id_from_flow_and_type($flow_id,$flow_type_id,$prjct_id);
		$tumprocessler = array();
		foreach ($array as $key => $a) {
			if($process_id!==$a['prcss_id']){
				$procesler = $cpscoping_model->get_process_from_allocatedpid_and_cmpny_id($a['prcss_id'],$cmpny_id);
				if(!empty($procesler)){
					$tumprocessler[$key] = $procesler;
					$tumprocessler[$key]['allocation_id']=$a['id'];
					$tumprocessler[$key]['allo_prcss_id']=$a['prcss_id'];
				}
			}
		}

		$allocated_processler = array();
		foreach ($tumprocessler as $t) {
			$allocated_processler[]=$cpscoping_model->get_allocation_from_allocation_id($t['allocation_id']);
		}

		header("Content-Type: application/json", true);
		echo json_encode($allocated_processler);
	}

	public function get_only_given_full($flow_id,$flow_type_id,$cmpny_id,$process_id){
		$flow_model = model(Flow_model::class);
		$result = $flow_model->get_company_flow($cmpny_id,$flow_id,$flow_type_id);
		header("Content-Type: application/json", true);
		echo json_encode($result);
	}

// 	public function get_allo_from_fname_pname($flow_id,$process_id,$cmpny_id,$input_output,$prjct_id){
// 		$cpscoping_model = model(Cpscoping_model::class);

// 		if($process_id != 0){
// 			$kontrol = array();
// 			$array = array();

// 			$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
// 			foreach ($allocation_ids as $allo_id) {
// 				$kontrol = $cpscoping_model->get_allocation_prcss_flow_id($allo_id['allocation_id'],$input_output);
// 				if(!empty($kontrol)){
// 					if($kontrol['prcss_id'] == $process_id && $kontrol['flow_id'] == $flow_id){
// 						$array = $kontrol;
// 						break;
// 					}
// 				}
// 			}
// 			$i = 0;
// 			$kontrol = array();
// 			$array_copy = array();
// 			foreach ($allocation_ids as $allo_id) {
// 				$kontrol = $cpscoping_model->get_allocation_from_fname_pname_copy($flow_id,$allo_id['allocation_id'],$input_output);
// 				if(!empty($kontrol)){
// 					$array_copy[$i] = $kontrol;
// 					$i++;
// 				}
// 			}
// 			if($i != 0){
// 				$kontrol = array();
// 				$amount = 0.0;
// 				for($k = 0 ; $k < $i ; $k++){
// 					$amount += $array_copy[$k]["amount"];
// 				}
// 				$amount_temp = $array['amount'];
// 				$amount_temp = ($amount_temp * 100) / $amount;
// 				$amount_array = array('allocation_rate' => number_format($amount_temp,2));
// 				$array = array_merge($array,$amount_array);
// 			}
// 		}else{
// 			$kontrol = array();
// 			$array = array();
// 			$i = 0;

// 			$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
// 			foreach ($allocation_ids as $allo_id) {
// 				$kontrol = $cpscoping_model->get_allocation_from_fname_pname_copy($flow_id,$allo_id['allocation_id'],$input_output);
// 				if(!empty($kontrol)){
// 					$array[$i] = $kontrol;
// 					$i++;
// 				}
// 			}
// 			if($i != 0){
// 				$kontrol = array();
// 				$amount = 0.0;
// 				$cost = 0.0;
// 				$env_impact = 0.0;
// 				for($k = 0 ; $k < $i ; $k++){
// 					$amount += $array[$k]["amount"];
// 					$cost += $array[$k]["cost"];
// 					$env_impact += $array[$k]["env_impact"];
// 				}
// 				$kontrol = array(
// 					'amount' => $amount,
// 					'unit_amount'=>$array[0]["unit_amount"],
// 					'cost' => $cost,
// 					'unit_cost'=>$array[0]["unit_cost"],
// 					'env_impact' => $env_impact,
// 					'error_ep' => $array[0]["error_ep"],
// 					'error_cost' => $array[0]["error_cost"],
// 					'error_amount' => $array[0]["error_amount"],
// 					'unit_env_impact'=>$array[0]["unit_env_impact"],
// 					'allocation_amount'=>"none"
// 				);
// 				$array = $kontrol;
// 			}
// 		}
// 		header("Content-Type: application/json", true);
// 		echo json_encode($array);
// 	}


// 	public function cp_allocation_array($company_id){
// 		$process_model = model(Process_model::class);
// 		$allocation_array = $process_model->get_cmpny_flow_prcss($company_id);
// 		header("Content-Type: application/json", true);
// 		echo json_encode($allocation_array);
// 	}

// 	public function cost_ep_value($prcss_id,$prjct_id,$cmpny_id){
// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$process_model = model(Process_model::class);
// 		$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
// 		$array = array();
// 		$index = 0;
// 		$cost_value_alt = 0.0;
// 		$cost_value_ust = 0.0;
// 		$ep_value_alt = 0.0;
// 		$ep_value_ust = 0.0;
// 		$cost_def_value = 0.0;
// 		$ep_def_value = 0.0;
// 		$prcss_name = "";
// 		foreach ($allocation_ids as $allo_id) {
// 			$array[$index] = $cpscoping_model->get_allocation_from_allocation_id($allo_id['allocation_id']);
// 			//print_r($array[$index]);
// 			if(!empty($array[$index]['prcss_id'])){
// 				if($array[$index]['prcss_id'] == $prcss_id){
// 					//dollar euro parse is not working, because the simple_html_dom is missing 
// 					// and the "doviz" page changed(nov. 2018)
// 					//$doviz_array = $this->dolar_euro_parse();
// 					$doviz_array = array("dollar" => 1, "euro" => 0.9);
// 					$unit = $array[$index]['unit_cost'];
// 					$error_cost = 100-$array[$index]['error_cost'];
// 					$error_amount = 100-$array[$index]['error_amount'];
// 					$error_ep = 100-$array[$index]['error_ep'];
// 					$allocation_env_impact = $array[$index]['allocation_env_impact'];

// 					if($unit == "Dollar"){
// 						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost)/100)) * number_format(($doviz_array['dollar'] / $doviz_array['euro']),4);
// 						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost)/100)) * number_format(($doviz_array['dollar'] / $doviz_array['euro']),4);
// 					}else if($unit == "TL"){
// 						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost/2)/100)) * $doviz_array['euro'];
// 						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost/2)/100)) * $doviz_array['euro'];
// 					}else{
// 						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost/2)/100));
// 						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost/2)/100));
// 					}

// 					$cost_def_value += $array[$index]['cost'];
// 					$prcss_name = $array[$index]['prcss_name'];
// 					$ep_def_value += $array[$index]['env_impact'];
// 					$ep_value_alt += $array[$index]['env_impact'] * ((100-$error_ep/2)/100);
// 					$ep_value_ust += $array[$index]['env_impact'] * ((100+$error_ep/2)/100);
// 					$process = $process_model->get_cmpny_prcss_from_id($cmpny_id,$array[$index]['prcss_id2']);

// 				}
// 			}
// 			$index++;
// 		}

// 		//print_r($process);
// 		$return_array = array(
// 			'prcss_name' => $prcss_name,
// 			'cost_def_value' => $cost_def_value,
// 			'ep_def_value' => $ep_def_value,
// 			'ep_value_alt' => $ep_value_alt,
// 			'ep_value_ust' => $ep_value_ust,
// 			'cost_value_alt' => $cost_value_alt,
// 			'cost_value_ust' => $cost_value_ust,
// 			'comment' => $process['comment'],
// 			'color' => '#' . str_pad(dechex(mt_rand(0, 0xFFFFFF)), 6, '0', STR_PAD_LEFT),
// 			'prcss_id' => $process['prcss_id']
// 		);
// 		header("Content-Type: application/json", true);
// 		echo json_encode($return_array);
// 	}

// 	public function dolar_euro_parse(){
// 		$sayac = 0;
// 		$array_temp = array();
// 		echo library('simple_html_dom');
// 		$raw = file_get_html('http://www.doviz.com/');
// 		foreach($raw->find('div') as $element){
// 		 	foreach ($element->find('ul') as $key) {
// 		  		foreach ($key->find('li') as $value) {
// 		  			foreach ($value->find('span') as $sp) {
// 		  				$sayac++;
// 		  				if($sayac == 8){
// 		  					$array_temp['dollar'] = str_replace(',', '.', $sp->plaintext);
// 		  				}else if($sayac == 13){
// 		  					$array_temp['euro'] = str_replace(',', '.', $sp->plaintext);
// 		  				}
// 			  		}
// 		  		}
// 		  	}
// 		}
// 		return $array_temp;
// 	}

// 	public function cp_is_candidate_control($allocation_id){
// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$return_array['control'] = $cpscoping_model->cp_is_candidate_control($allocation_id);
// 		header("Content-Type: application/json", true);
// 		echo json_encode($return_array);
// 	}

// 	public function cp_is_candidate_insert($allocation_id,$buton_durum){
// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$result = $cpscoping_model->cp_is_candidate_control($allocation_id);
// 		$is_candidate_array = array(
// 			'allocation_id' => $allocation_id,
// 			'active' => $buton_durum
// 		);
// 		if($result == 0){
// 			$cpscoping_model->cp_is_candidate_insert($is_candidate_array);
// 		}else{
// 			$cpscoping_model->cp_is_candidate_update($is_candidate_array,$allocation_id);
// 		}
// 	}

	public function cp_scoping_file_upload($prjct_id,$cmpny_id){
		$cpscoping_model = model(Cpscoping_model::class);

		$config['upload_path'] 			= './assets/cp_scoping_files/';
		$config['allowed_types']		= 'pdf|doc|docx';
		$config['max_size']				= '20000';

		echo library('upload', $config);
		
		if (!$this->upload->do_upload('docuFile'))
		{	
			//forwards error message to kpi_calculation() 
			$this->session->set_flashdata('error', $this->upload->display_errors());
 			redirect(base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id),'refresh');
		}
		else
		{
			$cp_scoping_files = array(
				'prjct_id' => $prjct_id,
				'cmpny_id' => $cmpny_id,
				'file_name' => $this->upload->data('file_name'),
			);

			//forwards data for successful upload to kpi_calculation()
			$cpscoping_model->insert_cp_scoping_file($cp_scoping_files);
			$this->session->set_flashdata('success', $this->upload->data());
			redirect(base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id),'refresh');
		}
	}

	public function file_delete($filename,$prjct_id,$cmpny_id){
		$cpscoping_model = model(Cpscoping_model::class);
		unlink("assets/cp_scoping_files/".$filename);
		$cp_scoping_files = array(
			'prjct_id' => $prjct_id,
			'cmpny_id' => $cmpny_id,
			'file_name' => $filename
		);
		$cpscoping_model->delete_cp_scoping_file($cp_scoping_files);
		redirect(base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id),'refresh');
	}

// 	public function search_result($prjct_id,$cmpny_id){
// 		$cpscoping_model = model(Cpscoping_model::class);
// 		$search = $this->request->getPost('search');
// 		$data['result'] = $cpscoping_model->search_result($search);
// 		$data['prjct_id'] = $prjct_id;
// 		$data['cmpny_id'] = $cmpny_id;
// 		echo view('template/header');
// 		echo view('cpscoping/search_result',$data);
// 		echo view('template/footer');
// 	}

// 	public function deneme(){
// 		echo view('template/header');
// 		echo view('cpscoping/deneme');
// 		echo view('template/footer');
// 	}

// 	public function deneme_json(){
// 		$user_model = model(User_model::class);
// 		$project_model = model(Project_model::class);
// 		$c_user = $user_model->get_session_user();
// 		$allocation_array = $user_model->deneme_json($c_user['id']);
// 		$i = 0;
// 		foreach ($allocation_array as $p) {
// 			$array = $project_model->deneme_json_2($p['id']);
// 			$allocation_array[$i]['children'] = $array;
// 			$i++;
// 		}
// 		header("Content-Type: application/json", true);
// 		echo json_encode($allocation_array);
// 	}

	public function kpi_calculation($prjct_id,$cmpny_id){
		$cpscoping_model = model(Cpscoping_model::class);
		$data['cp_files'] = $cpscoping_model->get_cp_scoping_files($prjct_id,$cmpny_id);
		$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		foreach ($allocation_ids as $allocation_id) {
			$data['kpi_values'][] = $cpscoping_model->get_allocation_from_allocation_id($allocation_id['allocation_id']);
		}

		$data['error'] = $this->session->getFlashdata('error');
		$data['success'] = $this->session->getFlashdata('success');

		echo view('template/header');
		echo view('cpscoping/kpi_calculation',$data);
		echo view('template/footer');
	}

	public function kpi_json($prjct_id,$cmpny_id){
		$cpscoping_model = model(Cpscoping_model::class);
		$data['cp_files'] = $cpscoping_model->get_cp_scoping_files($prjct_id,$cmpny_id);
		$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		
		foreach ($allocation_ids as $a => $key) {
			
					$data['kpi_values'][$a] = $cpscoping_model->get_allocation_from_allocation_id($key['allocation_id']);
					
					$data['kpi_values'][$a]['allocation_name']=$data['kpi_values'][$a]['prcss_name']." - ".$data['kpi_values'][$a]['flow_name']." - ".$data['kpi_values'][$a]['flow_type_name'];
					
					if(!isset($data['kpi_values'][$a]['option'])){
						$data['kpi_values'][$a]['option']=0;
					}
					if($data['kpi_values'][$a]['option']==1){
						$data['kpi_values'][$a]['option']="Option";
					}else{
						$data['kpi_values'][$a]['option']="Not An Option";
			}
		}
		header("Content-Type: application/json", true);
		echo json_encode($data['kpi_values']);
	}

// 	public function kpi_insert($prjct_id,$cmpny_id,$flow_id,$flow_type_id,$prcss_id,$allocation_id){
// 		$cpscoping_model = model(Cpscoping_model::class);

// 		//$return = $_POST;
		
// 		//$flag= is_numeric($return['benchmark_kpi']);
// 		$this->form_validation->set_error_delimiters("<span style='color:red; font-size:13px;'>"," Invalid row, please check...</span></br>");

// 		$this->form_validation->set_rules('benchmark_kpi', 'Benchmark Kpi', 'required|trim|xss_clean');
// 		$this->form_validation->set_rules('best_practice', 'Best Practice', 'trim|xss_clean');
// 		$this->form_validation->set_rules('description', 'Description', 'trim|xss_clean|max_length[500]');

// 		//$allocation_ids = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);

// 		if ($this->form_validation->run() !== FALSE){
// 			$benchmark_kpi = $_POST['benchmark_kpi'];
// 			$best_practice = $_POST['best_practice'];
// 			$option = $_POST['option'];
// 			$description = $_POST['description'];
// 			if($option=="Option"){$option=1;}else{$option=0;}
				
// 			$query = $cpscoping_model->get_allocation_from_allocation_id($allocation_id);
// 			if(!empty($query['flow_id'])){
// 				if($query['flow_id'] == $flow_id && $query['flow_type_id'] == $flow_type_id && $query['prcss_id'] == $prcss_id){
// 					$insert_array = array(
// 					  'benchmark_kpi' => $benchmark_kpi,
// 					  'best_practice' => $best_practice,
// 					  'option' => $option,
// 					  'description' => $description
// 					);
// 					$cpscoping_model->kpi_insert($insert_array,$allocation_id);
// 				   	$return = $query['prcss_name']." ".$query['flow_name']." ".$query['flow_type_name']."'s new data has been saved to database.</br>";
// 				}
// 			}
// 		}
// 		else{
// 			$return = validation_errors();
// 		}
// 		echo json_encode($return);
// 	}

// 	//to delete allocation (if the has rights to edit/update the project)
// 	public function delete_allocation($allocation_id,$project_id,$company_id){
// 		$user_model = model(User_model::class);
// 		$project_model = model(Project_model::class);
// 		$cpscoping_model = model(Cpscoping_model::class);

// 		$c_user = $user_model->get_session_user();
// 		if($project_model->can_update_project_information($c_user['id'], $project_id) == false){
// 			return redirect()->to(site_url());
// 		}else{
// 			$cpscoping_model->delete_allocation($allocation_id,$project_id,$company_id);
// 			return redirect()->to(site_url('cpscoping'));
// 		}
// 	}

// 	public function comment_save($cmpny_id,$prcss_id){
// 		$process_model = model(Process_model::class);
// 		$this->form_validation->set_error_delimiters('<div class="error">', '</div>');
// 		$this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

// 		if ($this->form_validation->run() !== FALSE){
// 			$comment = $_POST['comment'];
// 			$process_model->update_process_comment($cmpny_id,$prcss_id,$comment);
// 			$process = $process_model->get_process_from_process_id($prcss_id);
// 			$return = "<span style='color:darkblue; font-size:13px;'>Comment saved for ".$process['name']."</span><br>";
// 		}
// 		else{
// 			$return = "<span style='color:red; font-size:13px;'>".validation_errors()."</span>";
// 		}
// 		echo json_encode($return);
// 	}

}
