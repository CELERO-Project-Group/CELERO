<?php

namespace App\Controllers;

class Cpscoping extends BaseController {

	function __construct(){
		parent::__construct();
		$this->load->model('user_model');
		$this->load->model('project_model');		
		$this->load->model('product_model');		
		$this->load->model('process_model');
		$this->load->model('company_model');
		$this->load->model('cpscoping_model');
		$this->load->model('flow_model');
		$this->load->library('form_validation');
		$temp = $this->session->userdata('user_in');
		if(empty($temp)){
			redirect(base_url('login'),'refresh');
		}
				$this->config->set_item('language', $this->session->userdata('site_lang'));

	}

	public function index(){
		$c_user = $this->user_model->get_session_user();
		if($this->cpscoping_model->can_consultant_prjct($c_user['id']) == false){
			redirect('','refresh');
		}else{
			//$data['c_projects']=$this->user_model->get_consultant_projects_from_userid($c_user['id']);
			$result = array(array());
			$com_array = array();
			$i = 0;
			//foreach ($data['c_projects'] as $project_name) {
				$com_array = $this->project_model->get_prj_companies($this->session->userdata('project_id'));
				foreach ($com_array as $c) {
					$com_pro = array(
						"project_name" => $this->session->userdata('project_name'),
						"company_name" => $c['name'],
						"project_id" => $this->session->userdata('project_id'),
						"company_id" => $c['id']
					);
					$result[$i] = $com_pro;
					$i++;
				}
			//}
			$deneme = array(array());
			$j = 0;
			foreach ($result as $r) {
				$flow_prcss = $this->cpscoping_model->get_allocation_values($r['company_id'],$this->session->userdata('project_id'));
				$deneme[$j] = $flow_prcss;
				$j++;
			}
			$data['flow_prcss'] = $deneme;
			$data['com_pro'] = $result;
			$this->load->view('template/header');
			$this->load->view('cpscoping/index',$data);
			$this->load->view('template/footer');
		}
	}

	//Getting project companies from ajax
	public function p_companies($pid){
		$com_array = $this->project_model->get_prj_companies($pid);
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

	public function cp_allocation($project_id,$company_id){
		$this->form_validation->set_rules('prcss_name', 'Process Name', 'required|trim|xss_clean');
		$this->form_validation->set_rules('flow_name', 'Flow Name', 'required|trim|xss_clean');
		$this->form_validation->set_rules('flow_type_name', 'Flow Type Name', 'required|trim|xss_clean');
		
		$this->form_validation->set_rules('amount', 'Amount', 'required|trim|xss_clean');
		$this->form_validation->set_rules('allocation_amount', 'Amount Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_amount', 'Amount Error Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_amount', 'Unit Amount', 'required|trim|xss_clean');

		$this->form_validation->set_rules('cost', 'Cost', 'required|trim|xss_clean');
		$this->form_validation->set_rules('allocation_cost', 'Cost Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_cost', 'Cost Error Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_cost', 'Unit Cost', 'required|trim|xss_clean');
		
		$this->form_validation->set_rules('env_impact', 'Env. Impact', 'required|trim|max_length[25]|xss_clean');
		$this->form_validation->set_rules('allocation_env_impact', 'Env. Impact Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_ep', 'Env. Impact Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_env_impact', 'Unit Env. Impact', 'required|trim|xss_clean');

		$this->form_validation->set_rules('reference', 'Reference', 'required|trim|xss_clean');
		$this->form_validation->set_rules('unit_reference', 'Unit Reference', 'required|trim|xss_clean');
		$this->form_validation->set_rules('nameofref', 'Name of reference', 'trim|required|xss_clean');
		
		$this->form_validation->set_rules('kpi', 'Kpi', 'required|trim|xss_clean');
		$this->form_validation->set_rules('unit_kpi', ' Unit Kpi', 'required|trim|xss_clean');
		$this->form_validation->set_rules('kpidef', ' KPI definition', 'trim|xss_clean');
		//$this->form_validation->set_rules('kpi_error', 'Kpi Error', 'required|trim|integer|xss_clean');
		
		if ($this->form_validation->run() !== FALSE){
			$prcss_name = $this->input->post('prcss_name');
			$flow_name = $this->input->post('flow_name');
			$flow_type_name = $this->input->post('flow_type_name');
			$amount = $this->input->post('amount');
			$allocation_amount = $this->input->post('allocation_amount');
			$importance_amount = $this->input->post('error_amount');
			$cost = $this->input->post('cost');
			$allocation_cost = $this->input->post('allocation_cost');
			$importance_cost = $this->input->post('error_cost');
			$env_impact = $this->input->post('env_impact');
			$allocation_env_impact = $this->input->post('allocation_env_impact');
			$importance_env_impact = $this->input->post('error_ep');
			$unit_amount = $this->input->post('unit_amount');
			$unit_cost = $this->input->post('unit_cost');
			$unit_env_impact = $this->input->post('unit_env_impact');
			$reference = $this->input->post('reference');
			$unit_reference = $this->input->post('unit_reference');
			$kpi = $this->input->post('kpi');
			$unit_kpi = $this->input->post('unit_kpi');
			$kpidef = $this->input->post('kpidef');
			$nameofref = $this->input->post('nameofref');
			//$kpi_error = $this->input->post('kpi_error');

			$array_allocation = array(
				'prcss_id'=>$prcss_name,
				'flow_id'=>$flow_name,
				'flow_type_id'=>$flow_type_name,
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
				'unit_kpi' => $unit_kpi,
				'kpidef' => $kpidef,
				'nameofref' => $nameofref
			);
			$this->cpscoping_model->set_cp_allocation($array_allocation);
			$allocation_array = array(
				'allocation_id' => $this->db->insert_id(),
				'prjct_id' => $project_id,
				'cmpny_id' => $company_id
			);
			$this->cpscoping_model->set_cp_allocation_main($allocation_array);

			redirect('cpscoping/'.$project_id.'/'.$company_id.'/show');
		}
		$data['project_id'] = $project_id;
		$data['company_id'] = $company_id;
		$data['product'] = $this->product_model->get_product_list($company_id);
		$data['company_flows']=$this->flow_model->get_company_flow_list($company_id);
		$data['prcss_info'] = $this->process_model->get_cmpny_flow_prcss($company_id);
		$data['unit_list'] = $this->flow_model->get_unit_list();

		$array_temp = array();
		$temp_index = 0;
		$kontrol = array();
		$index = 0;
		foreach ($data['prcss_info'] as $prcss_info) {
			$deneme = 0;
			$kontrol[$index] = $prcss_info['prcessname'];
			$index++;
			for($k = 0 ; $k < $index - 1 ; $k++){
				if($kontrol[$k] == $prcss_info['prcessname']){
					$deneme = 1;
				}
			}
			if($deneme == 0){
				$array_temp[$temp_index] = $prcss_info;
				$temp_index++;
			}
		}

		$data['prcss_info'] = $array_temp;
 
		$this->load->view('template/header');
		$this->load->view('cpscoping/allocation',$data);
		$this->load->view('template/footer');
	}

	public function allocationlist($project_id,$company_id){
		$data['allocationlar'] = $this->cpscoping_model->get_allocation_values($company_id,$project_id);
		//print_r($data['allocationlar']);
		$data['companyID'] = $company_id;
		$data['company_info'] = $this->company_model->get_company($company_id);

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/allocationlist',$data);
		$this->load->view('template/footer');
	}

	public function cp_show_allocation($project_id,$company_id){
		$allocation_id_array = $this->cpscoping_model->get_allocation_id_from_ids($company_id,$project_id);
		$data['allocation'] = array();
		foreach ($allocation_id_array as $ids) {

			$ilkveri = $this->cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
			//print_r($ilkveri);
			
			if($ilkveri['prcss_id']!='0'){
				$prcss_name = $ilkveri['flow_id'].'-'.$ilkveri['prcss_id'].'-'.$ilkveri['flow_type_id'];
				$data['allocationveri'][$prcss_name] = $ilkveri;
				$prcss_total = $ilkveri['flow_id'].'-0-'.$ilkveri['flow_type_id'];
				if(!isset($data['allocationveri'][$prcss_total]['amount'])){
					$data['allocationveri'][$prcss_total]['amount'] = '0';
					$data['allocationveri'][$prcss_total]['unit_amount'] = '';
					$data['allocationveri'][$prcss_total]['cost'] = '0';
					$data['allocationveri'][$prcss_total]['unit_cost'] = '';
					$data['allocationveri'][$prcss_total]['env_impact'] = '0';
					$data['allocationveri'][$prcss_total]['unit_env_impact'] = '';
				}
				$data['allocationveri'][$prcss_total]['amount'] += $ilkveri['amount'];
				$data['allocationveri'][$prcss_total]['unit_amount'] = $ilkveri['unit_amount'];
				$data['allocationveri'][$prcss_total]['cost'] += $ilkveri['cost'];
				$data['allocationveri'][$prcss_total]['unit_cost'] = $ilkveri['unit_cost'];
				$data['allocationveri'][$prcss_total]['env_impact'] += $ilkveri['env_impact'];
				$data['allocationveri'][$prcss_total]['unit_env_impact'] = 'EP';
			}

			$data['allocation'][] = $this->cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
			//print_r($data['allocationveri']);
			//echo "<hr>";
			$data['allocation_output'][] = $this->cpscoping_model->get_allocation_from_allocation_id_output($ids['allocation_id']);
			$data['active'][$ids['allocation_id']] = $this->cpscoping_model->get_is_candidate_active_position($ids['allocation_id']);

		}
		//print_r($data);
		$this->load->view('template/header');
		$this->load->view('cpscoping/show',$data);
		$this->load->view('template/footer');
	}

	// Edit allocation function
	public function edit_allocation($allocation_id){
		
		$data['unit_list'] = $this->flow_model->get_unit_list();
		$data['allocation'] = $this->cpscoping_model->get_allocation_from_allocation_id($allocation_id);
		// check if allocation is not set or deleted
		if(empty($data['allocation'])) { redirect(site_url()); }
		//check if user has permission to edit
		$kullanici = $this->session->userdata('user_in');
		$permission= $this->user_model->can_edit_company($kullanici['id'],$data['allocation']['cmpny_id']);
		if($permission==FALSE){redirect(site_url());}


		$this->form_validation->set_rules('amount', 'Amount', 'required|trim|xss_clean');
		$this->form_validation->set_rules('allocation_amount', 'Amount Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_amount', 'Amount Error Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_amount', 'Unit Amount', 'required|trim|xss_clean');

		$this->form_validation->set_rules('cost', 'Cost', 'required|trim|xss_clean');
		$this->form_validation->set_rules('allocation_cost', 'Cost Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_cost', 'Cost Error Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_cost', 'Unit Cost', 'required|trim|xss_clean');
		
		$this->form_validation->set_rules('env_impact', 'Env. Impact', 'required|trim|xss_clean');
		$this->form_validation->set_rules('allocation_env_impact', 'Env. Impact Allocation', 'required|trim|max_length[7]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('error_ep', 'Env. Impact Rate', 'required|trim|integer|max_length[3]|greater_than[0]|xss_clean');
		$this->form_validation->set_rules('unit_env_impact', 'Unit Env. Impact', 'required|trim|xss_clean');

		$this->form_validation->set_rules('reference', 'Reference', 'required|trim|xss_clean');
		$this->form_validation->set_rules('unit_reference', 'Unit Reference', 'required|trim|xss_clean');
		
		$this->form_validation->set_rules('kpi', 'Kpi', 'required|trim|xss_clean');
		$this->form_validation->set_rules('unit_kpi', ' Unit Kpi', 'required|trim|xss_clean');
		$this->form_validation->set_rules('nameofref', ' Name of reference', 'trim|xss_clean|max_length[50]');
		$this->form_validation->set_rules('kpidef', ' KPI definition', 'trim|xss_clean|max_length[250]');


		if ($this->form_validation->run() !== FALSE){

			$amount = $this->input->post('amount');
			$allocation_amount = $this->input->post('allocation_amount');
			$importance_amount = $this->input->post('error_amount');
			$cost = $this->input->post('cost');
			$allocation_cost = $this->input->post('allocation_cost');
			$importance_cost = $this->input->post('error_cost');
			$env_impact = $this->input->post('env_impact');
			$allocation_env_impact = $this->input->post('allocation_env_impact');
			$importance_env_impact = $this->input->post('error_ep');
			$unit_amount = $this->input->post('unit_amount');
			$unit_cost = $this->input->post('unit_cost');
			$unit_env_impact = $this->input->post('unit_env_impact');
			$reference = $this->input->post('reference');
			$unit_reference = $this->input->post('unit_reference');
			$kpi = $this->input->post('kpi');
			$unit_kpi = $this->input->post('unit_kpi');
			$nameofref = $this->input->post('nameofref');
			$kpidef = $this->input->post('kpidef');
			//$kpi_error = $this->input->post('kpi_error');

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
			$this->cpscoping_model->update_cp_allocation($array_allocation,$allocation_id);

			redirect('cpscoping');
		}

		$this->load->view('template/header');
		$this->load->view('cpscoping/edit_allocation',$data);
		$this->load->view('template/footer');
	}

	public function kpi_calculation_chart($prjct_id,$cmpny_id){
		$allocation_id_array = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		$data['allocation'] = array();
		foreach ($allocation_id_array as $ids) {
			if(!empty($ids['allocation_id'])){
				$veri = $this->cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
				if(!empty($veri['allocation_id'])){
					$data['allocation'][] = $veri;
				}
			}
		}
		header("Content-Type: application/json", true);
		echo json_encode($data);
	}

	public function get_already_allocated_allocation_except_given($flow_id,$flow_type_id,$cmpny_id,$process_id,$prjct_id){
		//zero kontrol yap
		$array = $this->cpscoping_model->get_process_id_from_flow_and_type($flow_id,$flow_type_id,$prjct_id);
		//print_r($array);
		//echo "<hr>";

		$tumprocessler = array();
		foreach ($array as $key => $a) {
			if($process_id!==$a['prcss_id']){
				$procesler = $this->cpscoping_model->get_process_from_allocatedpid_and_cmpny_id($a['prcss_id'],$cmpny_id);
				if(!empty($procesler)){
					$tumprocessler[$key] = $procesler;
					$tumprocessler[$key]['allocation_id']=$a['id'];
					$tumprocessler[$key]['allo_prcss_id']=$a['prcss_id'];
				}
			}
		}
		//print_r($tumprocessler);
		//echo "<hr>";

		$allocated_processler = array();
		foreach ($tumprocessler as $t) {
			$allocated_processler[]=$this->cpscoping_model->get_allocation_from_allocation_id($t['allocation_id']);
		}
		//print_r($allocated_processler);

		//print json mode data
		header("Content-Type: application/json", true);
		echo json_encode($allocated_processler);
	}

	public function get_only_given_full($flow_id,$flow_type_id,$cmpny_id,$process_id){
		$result = $this->flow_model->get_company_flow($cmpny_id,$flow_id,$flow_type_id);
		//print_r($result);
		//print json mode data
		header("Content-Type: application/json", true);
		echo json_encode($result);
	}

	public function get_allo_from_fname_pname($flow_id,$process_id,$cmpny_id,$input_output,$prjct_id){
		if($process_id != 0){
			$kontrol = array();
			$array = array();

			$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
			foreach ($allocation_ids as $allo_id) {
				$kontrol = $this->cpscoping_model->get_allocation_prcss_flow_id($allo_id['allocation_id'],$input_output);
				if(!empty($kontrol)){
					if($kontrol['prcss_id'] == $process_id && $kontrol['flow_id'] == $flow_id){
						$array = $kontrol;
						break;
					}
				}
			}
			$i = 0;
			$kontrol = array();
			$array_copy = array();
			foreach ($allocation_ids as $allo_id) {
				$kontrol = $this->cpscoping_model->get_allocation_from_fname_pname_copy($flow_id,$allo_id['allocation_id'],$input_output);
				if(!empty($kontrol)){
					$array_copy[$i] = $kontrol;
					$i++;
				}
			}
			if($i != 0){
				$kontrol = array();
				$amount = 0.0;
				for($k = 0 ; $k < $i ; $k++){
					$amount += $array_copy[$k]["amount"];
				}
				$amount_temp = $array['amount'];
				$amount_temp = ($amount_temp * 100) / $amount;
				$amount_array = array('allocation_rate' => number_format($amount_temp,2));
				$array = array_merge($array,$amount_array);
			}
			/*$array = $this->cpscoping_model->get_allocation_from_fname_pname($flow_id,$process_id,$input_output);
			
			$cmpny_prcss_id = $this->process_model->get_cmpny_prcss_id($cmpny_id);
			$i = 0;
			$kontrol = array();
			foreach ($cmpny_prcss_id as $id) {
				$kontrol = $this->cpscoping_model->get_allocation_from_fname_pname($flow_id,$id['id'],$input_output);
				if(!empty($kontrol)){
					$array_copy[$i] = $kontrol;
					$i++;
				}
			}
			if($i != 0){
				$kontrol = array();
				$amount = 0.0;
				for($k = 0 ; $k < $i ; $k++){
					$amount += $array_copy[$k]["amount"];
				}
				$amount_temp = $array['amount'];
				$amount_temp = ($amount_temp * 100) / $amount;
				$amount_array = array('allocation_rate' => number_format($amount_temp,2));
				$array = array_merge($array,$amount_array);
			}*/
		}else{
			$kontrol = array();
			$array = array();
			$i = 0;

			$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
			foreach ($allocation_ids as $allo_id) {
				$kontrol = $this->cpscoping_model->get_allocation_from_fname_pname_copy($flow_id,$allo_id['allocation_id'],$input_output);
				if(!empty($kontrol)){
					$array[$i] = $kontrol;
					$i++;
				}
			}
			if($i != 0){
				$kontrol = array();
				$amount = 0.0;
				$cost = 0.0;
				$env_impact = 0.0;
				for($k = 0 ; $k < $i ; $k++){
					$amount += $array[$k]["amount"];
					$cost += $array[$k]["cost"];
					$env_impact += $array[$k]["env_impact"];
				}
				$kontrol = array(
					'amount' => $amount,
					'unit_amount'=>$array[0]["unit_amount"],
					'cost' => $cost,
					'unit_cost'=>$array[0]["unit_cost"],
					'env_impact' => $env_impact,
					'error_ep' => $array[0]["error_ep"],
					'error_cost' => $array[0]["error_cost"],
					'error_amount' => $array[0]["error_amount"],
					'unit_env_impact'=>$array[0]["unit_env_impact"],
					'allocation_amount'=>"none"
				);
				$array = $kontrol;
			}
			/*$cmpny_prcss_id = $this->process_model->get_cmpny_prcss_id($cmpny_id);
			$i = 0;
			$kontrol = array();
			foreach ($cmpny_prcss_id as $id) {
				$kontrol = $this->cpscoping_model->get_allocation_from_fname_pname($flow_id,$id['id'],$input_output);
				if(!empty($kontrol)){
					$array[$i] = $kontrol;
					$i++;
				}
			}
			if($i != 0){
				$kontrol = array();
				$amount = 0.0;
				$cost = 0.0;
				$env_impact = 0.0;
				for($k = 0 ; $k < $i ; $k++){
					$amount += $array[$k]["amount"];
					$cost += $array[$k]["cost"];
					$env_impact += $array[$k]["env_impact"];
				}
				$kontrol = array(
					'amount' => $amount,
					'unit_amount'=>$array[0]["unit_amount"],
					'cost' => $cost,
					'unit_cost'=>$array[0]["unit_cost"],
					'env_impact' => $env_impact,
					'unit_env_impact'=>$array[0]["unit_env_impact"],
					'allocation_amount'=>"none"
				);
				$array = $kontrol;
			}*/
		}
		header("Content-Type: application/json", true);
		echo json_encode($array);
	}


	public function cp_allocation_array($company_id){
		$allocation_array = $this->process_model->get_cmpny_flow_prcss($company_id);
		header("Content-Type: application/json", true);
		echo json_encode($allocation_array);
	}

	public function cost_ep_value($prcss_id,$prjct_id,$cmpny_id){
		$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		$array = array();
		$index = 0;
		$cost_value_alt = 0.0;
		$cost_value_ust = 0.0;
		$ep_value_alt = 0.0;
		$ep_value_ust = 0.0;
		$cost_def_value = 0.0;
		$ep_def_value = 0.0;
		$prcss_name = "";
		foreach ($allocation_ids as $allo_id) {
			$array[$index] = $this->cpscoping_model->get_allocation_from_allocation_id($allo_id['allocation_id']);
			//print_r($array[$index]);
			if(!empty($array[$index]['prcss_id'])){
				if($array[$index]['prcss_id'] == $prcss_id){
					//dollar euro parse is not working, because the simple_html_dom is missing 
					// and the "doviz" page changed(nov. 2018)
					//$doviz_array = $this->dolar_euro_parse();
					$doviz_array = array("dollar" => 1, "euro" => 0.9);
					$unit = $array[$index]['unit_cost'];
					$error_cost = 100-$array[$index]['error_cost'];
					$error_amount = 100-$array[$index]['error_amount'];
					$error_ep = 100-$array[$index]['error_ep'];
					$allocation_env_impact = $array[$index]['allocation_env_impact'];

					if($unit == "Dollar"){
						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost)/100)) * number_format(($doviz_array['dollar'] / $doviz_array['euro']),4);
						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost)/100)) * number_format(($doviz_array['dollar'] / $doviz_array['euro']),4);
					}else if($unit == "TL"){
						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost/2)/100)) * $doviz_array['euro'];
						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost/2)/100)) * $doviz_array['euro'];
					}else{
						$cost_value_alt += ($array[$index]['cost'] * ((100-$error_cost/2)/100));
						$cost_value_ust += ($array[$index]['cost'] * ((100+$error_cost/2)/100));
					}

					$cost_def_value += $array[$index]['cost'];
					$prcss_name = $array[$index]['prcss_name'];
					$ep_def_value += $array[$index]['env_impact'];
					$ep_value_alt += $array[$index]['env_impact'] * ((100-$error_ep/2)/100);
					$ep_value_ust += $array[$index]['env_impact'] * ((100+$error_ep/2)/100);
					$process = $this->process_model->get_cmpny_prcss_from_id($cmpny_id,$array[$index]['prcss_id2']);

				}
			}
			$index++;
		}

		//print_r($process);
		$return_array = array(
			'prcss_name' => $prcss_name,
			'cost_def_value' => $cost_def_value,
			'ep_def_value' => $ep_def_value,
			'ep_value_alt' => $ep_value_alt,
			'ep_value_ust' => $ep_value_ust,
			'cost_value_alt' => $cost_value_alt,
			'cost_value_ust' => $cost_value_ust,
			'comment' => $process['comment'],
			'color' => '#' . str_pad(dechex(mt_rand(0, 0xFFFFFF)), 6, '0', STR_PAD_LEFT),
			'prcss_id' => $process['prcss_id']
		);
		header("Content-Type: application/json", true);
		echo json_encode($return_array);
	}

	public function dolar_euro_parse(){
		$sayac = 0;
		$array_temp = array();
		$this->load->library('simple_html_dom');
		$raw = file_get_html('http://www.doviz.com/');
		foreach($raw->find('div') as $element){
		 	foreach ($element->find('ul') as $key) {
		  		foreach ($key->find('li') as $value) {
		  			foreach ($value->find('span') as $sp) {
		  				$sayac++;
		  				if($sayac == 8){
		  					$array_temp['dollar'] = str_replace(',', '.', $sp->plaintext);
		  				}else if($sayac == 13){
		  					$array_temp['euro'] = str_replace(',', '.', $sp->plaintext);
		  				}
			  		}
		  		}
		  	}
		}
		return $array_temp;
	}

	public function cp_is_candidate_control($allocation_id){
		$return_array['control'] = $this->cpscoping_model->cp_is_candidate_control($allocation_id);
		header("Content-Type: application/json", true);
		echo json_encode($return_array);
	}

	public function cp_is_candidate_insert($allocation_id,$buton_durum){
		$result = $this->cpscoping_model->cp_is_candidate_control($allocation_id);
		$is_candidate_array = array(
			'allocation_id' => $allocation_id,
			'active' => $buton_durum
		);
		if($result == 0){
			$this->cpscoping_model->cp_is_candidate_insert($is_candidate_array);
		}else{
			$this->cpscoping_model->cp_is_candidate_update($is_candidate_array,$allocation_id);
		}
	}

	public function cp_scoping_file_upload($prjct_id,$cmpny_id){
		$config['upload_path'] 			= './assets/cp_scoping_files/';
		$config['allowed_types']		= 'pdf|doc|docx';
		$config['max_size']				= '20000';

		$this->load->library('upload', $config);
		
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
        	$this->cpscoping_model->insert_cp_scoping_file($cp_scoping_files);
			$this->session->set_flashdata('success', $this->upload->data());
			redirect(base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id),'refresh');
        }
	}

	public function file_delete($filename,$prjct_id,$cmpny_id){
		unlink("assets/cp_scoping_files/".$filename);
		$cp_scoping_files = array(
			'prjct_id' => $prjct_id,
			'cmpny_id' => $cmpny_id,
			'file_name' => $filename
		);
		$this->cpscoping_model->delete_cp_scoping_file($cp_scoping_files);
		redirect(base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id),'refresh');
	}

	public function search_result($prjct_id,$cmpny_id){
		$search = $this->input->post('search');
		$data['result'] = $this->cpscoping_model->search_result($search);
		$data['prjct_id'] = $prjct_id;
		$data['cmpny_id'] = $cmpny_id;
		$this->load->view('template/header');
		$this->load->view('cpscoping/search_result',$data);
		$this->load->view('template/footer');
	}

	public function deneme(){
		$this->load->view('template/header');
		$this->load->view('cpscoping/deneme');
		$this->load->view('template/footer');
	}

	public function deneme_json(){
		$c_user = $this->user_model->get_session_user();
		$allocation_array = $this->user_model->deneme_json($c_user['id']);
		$i = 0;
		foreach ($allocation_array as $p) {
			$array = $this->project_model->deneme_json_2($p['id']);
			$allocation_array[$i]['children'] = $array;
			$i++;
		}
		header("Content-Type: application/json", true);
		echo json_encode($allocation_array);
	}

	public function kpi_calculation($prjct_id,$cmpny_id){
		$data['cp_files'] = $this->cpscoping_model->get_cp_scoping_files($prjct_id,$cmpny_id);
		$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		foreach ($allocation_ids as $allocation_id) {
			$data['kpi_values'][] = $this->cpscoping_model->get_allocation_from_allocation_id($allocation_id['allocation_id']);
		}

		$data['error'] = $this->session->flashdata('error');
		$data['success'] = $this->session->flashdata('success');

		$this->load->view('template/header');
		$this->load->view('cpscoping/kpi_calculation',$data);
		$this->load->view('template/footer');
	}

	public function kpi_json($prjct_id,$cmpny_id){
		$data['cp_files'] = $this->cpscoping_model->get_cp_scoping_files($prjct_id,$cmpny_id);
		$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
		
		foreach ($allocation_ids as $a => $key) {
			
					$data['kpi_values'][$a] = $this->cpscoping_model->get_allocation_from_allocation_id($key['allocation_id']);
					
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
		//print_r($this->cpscoping_model->get_allocation_from_allocation_id('76'));
	}

	public function kpi_insert($prjct_id,$cmpny_id,$flow_id,$flow_type_id,$prcss_id,$allocation_id){

		//$return = $_POST;
		
		//$flag= is_numeric($return['benchmark_kpi']);
		$this->form_validation->set_error_delimiters("<span style='color:red; font-size:13px;'>"," Invalid row, please check...</span></br>");

		$this->form_validation->set_rules('benchmark_kpi', 'Benchmark Kpi', 'required|trim|xss_clean');
		$this->form_validation->set_rules('best_practice', 'Best Practice', 'trim|xss_clean');
		$this->form_validation->set_rules('description', 'Description', 'trim|xss_clean|max_length[500]');

		//$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);

		if ($this->form_validation->run() !== FALSE){
			$benchmark_kpi = $_POST['benchmark_kpi'];
			$best_practice = $_POST['best_practice'];
			$option = $_POST['option'];
			$description = $_POST['description'];
			if($option=="Option"){$option=1;}else{$option=0;}
				
			$query = $this->cpscoping_model->get_allocation_from_allocation_id($allocation_id);
			if(!empty($query['flow_id'])){
				if($query['flow_id'] == $flow_id && $query['flow_type_id'] == $flow_type_id && $query['prcss_id'] == $prcss_id){
					$insert_array = array(
				      'benchmark_kpi' => $benchmark_kpi,
				      'best_practice' => $best_practice,
				      'option' => $option,
				      'description' => $description
				    );
				    $this->cpscoping_model->kpi_insert($insert_array,$allocation_id);
				   	$return = $query['prcss_name']." ".$query['flow_name']." ".$query['flow_type_name']."'s new data has been saved to database.</br>";
				}
			}
		}
		else{
			$return = validation_errors();
		}
		echo json_encode($return);


		//$this->form_validation->set_rules('benchmark_kpi', 'Benchmark Kpi', 'required|trim|xss_clean');
		//$this->form_validation->set_rules('best_practice', 'Best Practice', 'trim|xss_clean');
			//
			//echo $benchmark_kpi;
			//echo $best_practice;
			//print_r($return);
			//echo "tuna";
			/*
		$allocation_ids = $this->cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);

		if ($this->form_validation->run() !== FALSE){
			$benchmark_kpi = $this->input->post('benchmark_kpi');
			$best_practice = $this->input->post('best_practice');

			foreach ($allocation_ids as $allo_id) {
				$query = $this->cpscoping_model->get_allocation_from_allocation_id($allo_id['allocation_id']);
				if(!empty($query['flow_id'])){
					if($query['flow_id'] == $flow_id && $query['flow_type_id'] == $flow_type_id && $query['prcss_id'] == $prcss_id){
						$insert_array = array(
					      'benchmark_kpi' => $benchmark_kpi,
					      'best_practice' => $best_practice
					    );
					    $this->cpscoping_model->kpi_insert($insert_array,$allo_id['allocation_id']);
					}
				}
			}
		}

		foreach ($allocation_ids as $allocation_id) {
			$data['kpi_values'][] = $this->cpscoping_model->get_allocation_from_allocation_id($allocation_id['allocation_id']);
		}
		$data['cp_files'] = $this->cpscoping_model->get_cp_scoping_files($prjct_id,$cmpny_id);

		$this->load->view('template/header');
		$this->load->view('cpscoping/kpi_calculation',$data);
		$this->load->view('template/footer');
		*/
	}

	//to delete allocation (if the has rights to edit/update the project)
	public function delete_allocation($allocation_id,$project_id,$company_id){
		$c_user = $this->user_model->get_session_user();
		if($this->project_model->can_update_project_information($c_user['id'], $project_id) == false){
			redirect(base_url(''),'refresh');
		}else{
			$this->cpscoping_model->delete_allocation($allocation_id,$project_id,$company_id);
			redirect(base_url('cpscoping'),'refresh');
		}
	}

	public function comment_save($cmpny_id,$prcss_id){

		//$return = $_POST;
		
		//$flag= is_numeric($return['benchmark_kpi']);
		$this->form_validation->set_error_delimiters('<div class="error">', '</div>');

		$this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

		if ($this->form_validation->run() !== FALSE){
			$comment = $_POST['comment'];
			$this->process_model->update_process_comment($cmpny_id,$prcss_id,$comment);
			$process = $this->process_model->get_process_from_process_id($prcss_id);
			$return = "<span style='color:darkblue; font-size:13px;'>Comment saved for ".$process['name']."</span><br>";
		}
		else{
			$return = "<span style='color:red; font-size:13px;'>".validation_errors()."</span>";
		}
		echo json_encode($return);
	}

}