<?php

namespace App\Controllers;

class Dataset extends BaseController {

	function __construct(){
		parent::__construct();
		$this->load->model('product_model');
		$this->load->model('user_model');
		$this->load->model('company_model');
		$this->load->model('flow_model');
		$this->load->model('process_model');
		$this->load->model('equipment_model');
		$this->load->model('component_model');
		$this->load->model('cpscoping_model');
		$this->load->library('form_validation');
	    header('Access-Control-Allow-Origin: *');
	    header("Access-Control-Allow-Headers: X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method");
	    header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
	    $method = $_SERVER['REQUEST_METHOD'];
	    if($method == "OPTIONS") {
	        die();
	    }


		$this->config->set_item('language', $session->get('site_lang'));

		$kullanici = $session->get('user_in');
		//TO-DO: blocking ajax to work.
		/*if($this->user_model->can_edit_company($kullanici['id'],$this->uri->segment(2)) == FALSE && $this->uri->segment(1) != "get_equipment_type" && $this->uri->segment(1) != "get_equipment_attribute"&& $this->uri->segment(1) != "get_sub_process"){
			redirect(base_url(''), 'refresh');
		}*/
	}

	function sifirla($data){
		if(empty($data)) return 0;
		else return $data;
	}

	public function new_product($companyID)
	{
		$this->form_validation->set_rules('product', 'Product Field', 'trim|required|xss_clean');
		$this->form_validation->set_rules('quantities', 'Product Quantity', 'trim|numeric|xss_clean');
		$this->form_validation->set_rules('ucost', 'Unit Cost', 'trim|numeric|xss_clean');
		$this->form_validation->set_rules('ucostu', 'Unit Cost Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('qunit', 'Quantity Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('tper', 'Time Period', 'trim|xss_clean');

		if($this->form_validation->run() !== FALSE) {
			$productArray = array(
					'cmpny_id' => $companyID,
					'name' => $this->input->post('product'),
					'quantities' => $this->sifirla($this->input->post('quantities')),
					'ucost' => $this->sifirla($this->input->post('ucost')),
					'ucostu' => $this->input->post('ucostu'),
					'qunit' => $this->input->post('qunit'),
					'tper' => $this->input->post('tper'),
				);
			$this->product_model->set_product($productArray);
		}

		$data['product'] = $this->product_model->get_product_list($companyID);
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/new_product',$data);
		$this->load->view('template/footer');
	}

	public function edit_product($companyID,$product_id)
	{
		$this->form_validation->set_rules('product', 'Product Field', 'trim|required|xss_clean');
		$this->form_validation->set_rules('quantities', 'Product Quantity', 'trim|numeric|xss_clean');
		$this->form_validation->set_rules('ucost', 'Unit Cost', 'trim|numeric|xss_clean');
		$this->form_validation->set_rules('ucostu', 'Unit Cost Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('qunit', 'Quantity Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('tper', 'Time Period', 'trim|xss_clean');

		if($this->form_validation->run() !== FALSE) {
			$productArray = array(
					'cmpny_id' => $companyID,
					'name' => $this->input->post('product'),
					'quantities' => $this->sifirla($this->input->post('quantities')),
					'ucost' => $this->sifirla($this->input->post('ucost')),
					'ucostu' => $this->input->post('ucostu'),
					'qunit' => $this->input->post('qunit'),
					'tper' => $this->input->post('tper'),
				);
			$this->product_model->update_product($companyID,$product_id,$productArray);
			redirect(base_url('new_product/'.$companyID), 'refresh'); // tablo olusurken ajax kullan�labilir.

		}

		$data['product'] = $this->product_model->get_product_by_cid_pid($companyID,$product_id);
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/edit_product',$data);
		$this->load->view('template/footer');
	}

	public function new_flow($companyID)
	{
		//checks permissions, if not loged in a redirect happens
		$user = $session->get('user_in');
		if(empty($user)){
			redirect('', 'refresh');
		}

		$this->form_validation->set_rules('flowname', 'Flow Name', 'trim|required|xss_clean|strip_tags|callback_alpha_dash_space');
		$this->form_validation->set_rules('flowtype', 'Flow Type', 'trim|required|xss_clean|strip_tags|callback_flow_varmi');
		$this->form_validation->set_rules('quantity', 'Quantity', 
			"trim|required|xss_clean|strip_tags|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]|max_length[8]");
		$this->form_validation->set_rules('quantityUnit', 'Quantity Unit', 'trim|required|xss_clean|strip_tags');
		$this->form_validation->set_rules('cost', 'Cost', "trim|required|xss_clean|strip_tags|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]|max_length[8]");
		$this->form_validation->set_rules('costUnit', 'Cost Unit', 'trim|required|xss_clean|strip_tags');
		$this->form_validation->set_rules('ep', 'EP', 
			"trim|xss_clean|strip_tags|max_length[25]|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]");
		$this->form_validation->set_rules('epUnit', 'EP Unit', 'trim|xss_clean|strip_tags');
		$this->form_validation->set_rules('charactertype', 'Flow Character Type', 'trim|xss_clean|strip_tags|max_length[50]');
		$this->form_validation->set_rules('availability', 'Availability', 'trim|xss_clean');
		$this->form_validation->set_rules('cf', 'Chemical Formula', 'trim|xss_clean|max_length[30]');
		$this->form_validation->set_rules('conc', 'Concentration', 'trim|xss_clean|strip_tags|numeric');
		$this->form_validation->set_rules('concunit', 'Concentration Unti', 'trim|xss_clean');
		$this->form_validation->set_rules('pres', 'Pressure', 'trim|xss_clean|strip_tags|numeric|max_length[10]');
		$this->form_validation->set_rules('presunit', 'Pressure Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('ph', 'PH', 'trim|xss_clean|strip_tags|numeric|max_length[10]');
		$this->form_validation->set_rules('state', 'State', 'trim|xss_clean');
		$this->form_validation->set_rules('quality', 'Quality', 'trim|xss_clean|max_length[150]');
		$this->form_validation->set_rules('oloc', 'Output Location', 'trim|xss_clean');
		$this->form_validation->set_rules('spot', 'Substitution Potential', 'trim|xss_clean');
		$this->form_validation->set_rules('desc', 'Description', 'trim|xss_clean|max_length[500]');
		$this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

		if($this->form_validation->run() !== FALSE) {

			$data['flownames'] = $this->flow_model->get_flowname_list();

			//do we need to replace spaces with _ anymore? str_replace(' ', '_', $variable);
			$flowID = $this->input->post('flowname');
			//and make it to lower case? Its anyway predefined right now
			//$flowID = strtolower($flowID);

			//if the flow already exists the id is used, 
			// other wise the name is used an new flow enty is created with is_new_flow($flowID,$flowfamilyID);
			foreach ($data['flownames'] as $flowname) {
				if ($flowID == $flowname['name']) {
					$flowID = $flowname['id'];
				}
			}


			$charactertype = $this->input->post('charactertype');
			$flowtypeID = $this->input->post('flowtype');
			$flowfamilyID = $this->input->post('flowfamily');

			//checks if flow already exist (as input OR output), same as flow_varmi()
			$companyID = $this->uri->segment(2);
			if(is_numeric($flowID)){
				if(!$this->flow_model->has_same_flow($flowID,$flowtypeID,$companyID)){
					$this->session->set_flashdata('message', 'Flow can only be added twice (as input and output), please check your flows.');
					//print_r("false");
			    	redirect(current_url());
				}
			}


			//CHECKs IF FLOW IS NEW (old flows have their IDs)
			$flowID = $this->process_model->is_new_flow($flowID,$flowfamilyID);

			#EP input field: By regex_match , . and ' are allowed.
			#this replaces , with . and removes thousand separator ' to store numeric in DB later
			$ep = $this->numeric_input_formater($this->input->post('ep'));
			$epUnit = $this->input->post('epUnit');

			#Cost input field: By regex_match , . and ' are allowed.
			#this replaces , with . and removes thousand separator ' to store numeric in DB later
			$cost = $this->numeric_input_formater($this->input->post('cost'));
			$costUnit = $this->input->post('costUnit');

			#Quantity input field: By regex_match , . and ' are allowed.
			#this replaces , with . and removes thousand separator ' to store numeric in DB later
			$quantity = $this->numeric_input_formater($this->input->post('quantity'));
			$quantityUnit = $this->input->post('quantityUnit');

			$data['units'] = $this->flow_model->get_unit_list();
			//the quantity unit gets passed as string but is predefined! User has only a specific set of units to chose from
			foreach ($data['units'] as $unit) {
				//if the submited unit matches the unit array, the id is assigned
				if ($quantityUnit == $unit['name']) {
					$quantityUnit = $unit['id'];
				}
				else {
					#todo what about those special units?
					#add them to the DB manually....
				}
			}
			
			$cf = $this->input->post('cf');
			$availability = $this->input->post('availability');
			$conc = $this->input->post('conc');
			$concunit = $this->input->post('concunit');
			$pres = $this->input->post('pres');
			$presunit = $this->input->post('presunit');
			$ph = $this->input->post('ph');
			$state = $this->input->post('state');
			$quality = $this->input->post('quality');
			$oloc = $this->input->post('oloc');
			$desc = $this->input->post('desc');
			$spot = $this->input->post('spot');
			$comment = $this->input->post('comment');

			$flow = array(
				'cmpny_id'=>$companyID,
				'flow_id'=>$flowID,
				'character_type'=>$charactertype,
				'qntty'=>$this->sifirla($quantity),
				'qntty_unit_id'=>$this->sifirla($quantityUnit),
				'cost' =>$this->sifirla($cost),
				'cost_unit_id' =>$costUnit,
				'ep' => $this->sifirla($ep),
				'ep_unit_id' => $epUnit,
				'flow_type_id'=> $this->sifirla($flowtypeID),
				'chemical_formula' => $cf,
				'availability' => $availability,
				'state_id' => $state,
				'quality' => $quality,
				'output_location' => $oloc,
				'substitute_potential' => $spot,
				'description' => $desc,
				'comment' => $comment
			);
			if(!empty($conc)){
				$flow['concentration'] = $conc;
				$flow['concunit'] = $concunit;
			}
			if(!empty($pres)){
				$flow['pression'] = $pres;
				$flow['presunit'] = $presunit;
			}
			if(!empty($ph)){
				$flow['ph'] = $ph;
			}

			$this->flow_model->register_flow_to_company($flow);
			redirect(current_url());
		}

		$data['flowtypes'] = $this->flow_model->get_flowtype_list();
		$data['flowfamilys'] = $this->flow_model->get_flowfamily_list();
		$data['company_flows']=$this->flow_model->get_company_flow_list($companyID);
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		
		$data['user'] = $session->get('user_in');

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/new_flow',$data);
		$this->load->view('template/footer');

	}

	public function edit_flow($companyID,$flow_id,$flow_type_id)
	{
		$this->form_validation->set_rules('quantity', 'Quantity', 'trim|required|xss_clean|strip_tags|numeric');
		$this->form_validation->set_rules('quantityUnit', 'Quantity Unit', 'trim|required|xss_clean|strip_tags');
		$this->form_validation->set_rules('cost', 'Cost', 'trim|required|xss_clean|strip_tags|numeric');
		$this->form_validation->set_rules('costUnit', 'Cost Unit', 'trim|required|xss_clean|strip_tags');
		$this->form_validation->set_rules('ep', 'EP', 'trim|xss_clean|strip_tags|numeric');
		$this->form_validation->set_rules('epUnit', 'EP Unit', 'trim|xss_clean|strip_tags');

		$this->form_validation->set_rules('charactertype', 'Flow Character Type', 'trim|xss_clean|strip_tags|max_length[50]');
		$this->form_validation->set_rules('availability', 'Availability', 'trim|xss_clean');
		$this->form_validation->set_rules('cf', 'Chemical Formula', 'trim|xss_clean|max_length[100]');
		$this->form_validation->set_rules('conc', 'Concentration', 'trim|xss_clean|strip_tags|numeric');
		$this->form_validation->set_rules('concunit', 'Concentration Unti', 'trim|xss_clean');
		$this->form_validation->set_rules('pres', 'Pressure', 'trim|xss_clean|strip_tags|numeric|max_length[14]');
		$this->form_validation->set_rules('presunit', 'Pressure Unit', 'trim|xss_clean');
		$this->form_validation->set_rules('ph', 'PH', 'trim|xss_clean|strip_tags|numeric|max_length[14]');
		$this->form_validation->set_rules('state', 'State', 'trim|xss_clean');
		$this->form_validation->set_rules('quality', 'Quality', 'trim|xss_clean|max_length[150]');
		$this->form_validation->set_rules('oloc', 'Output Location', 'trim|xss_clean');
		$this->form_validation->set_rules('spot', 'Substitution Potential', 'trim|xss_clean');
		$this->form_validation->set_rules('desc', 'Description', 'trim|xss_clean|max_length[500]');
		$this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

		if($this->form_validation->run() !== FALSE) {

			$charactertype = $this->input->post('charactertype');
			$ep = $this->input->post('ep');
			$epUnit = $this->input->post('epUnit');
			$cost = $this->input->post('cost');
			$costUnit = $this->input->post('costUnit');
			$quantity = $this->input->post('quantity');
			$quantityUnit = $this->input->post('quantityUnit');

			$cf = $this->input->post('cf');
			$availability = $this->input->post('availability');
			$conc = $this->input->post('conc');
			$concunit = $this->input->post('concunit');
			$pres = $this->input->post('pres');
			$presunit = $this->input->post('presunit');
			$ph = $this->input->post('ph');
			$state = $this->input->post('state');
			$quality = $this->input->post('quality');
			$oloc = $this->input->post('oloc');
			//$odis = $this->input->post('odis');
			//$otrasmean = $this->input->post('otrasmean');
			//$sdis = $this->input->post('sdis');
			//$strasmean = $this->input->post('strasmean');
			//$rtech = $this->input->post('rtech');
			$desc = $this->input->post('desc');
			$spot = $this->input->post('spot');
			$comment = $this->input->post('comment');

			$flow = array(
				'character_type'=>$charactertype,
				'qntty'=>$this->sifirla($quantity),
				'qntty_unit_id'=>$this->sifirla($quantityUnit),
				'cost' =>$this->sifirla($cost),
				'cost_unit_id' =>$costUnit,
				'ep' => $this->sifirla($ep),
				'ep_unit_id' => $epUnit,
				'chemical_formula' => $cf,
				'availability' => $availability,
				'state_id' => $state,
				'quality' => $quality,
				'output_location' => $oloc,
				'substitute_potential' => $spot,
				'description' => $desc,
				'comment' => $comment
			);
			if(!empty($conc)){
				$flow['concentration'] = $conc;
				$flow['concunit'] = $concunit;
			}
			if(!empty($pres)){
				$flow['pression'] = $pres;
				$flow['presunit'] = $presunit;
			}
			if(!empty($ph)){
				$flow['ph'] = $ph;
			}

			$this->flow_model->update_flow_info($companyID,$flow_id,$flow_type_id,$flow);

			redirect(base_url('new_flow/'.$companyID), 'refresh'); // tablo olusurken ajax kullan�labilir.
			//�uan sayfa yenileniyor her seferinde database'den sat�rlar ekleniyor.

		}

		$data['flow']=$this->flow_model->get_company_flow($companyID,$flow_id,$flow_type_id);
		if(empty($data['flow'])){
			redirect(base_url(), 'refresh'); // tablo olusurken ajax kullan�labilir.
		}
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/edit_flow',$data);
		$this->load->view('template/footer');

	}

	function flow_varmi()
	{
		$flowID = $this->input->post('flowname');
		$flowtypeID = $this->input->post('flowtype');
		$companyID = $this->uri->segment(2);
		if(is_numeric($flowID)){
			if(!$this->flow_model->has_same_flow($flowID,$flowtypeID,$companyID)){
				$this->form_validation->set_message('flow_varmi', 'Flow name already exists, please choose another name or edit existing flow.');
		    return false;
			}
			else{
				return true;
			}
		}
		else{
			return true;
		}

	}

	function alpha_dash_space($str)
	{
	  return ( ! preg_match("/^([-a-z0-9_ ])+$/i", $str)) ? FALSE : TRUE;
	}

	function numeric_input_formater($int)
	{
		#replaces , with . and thousand separator ' with nothing
		$int = str_replace(',', '.', $int);
		$int = str_replace("'", '', $int);
	  	return $int;
	}

	public function new_component($companyID){

		$this->form_validation->set_rules('component_name', 'Component Name', 'trim|required|xss_clean');
		$this->form_validation->set_rules('flowtype', 'Flow Type', 'trim|xss_clean');

		if($this->form_validation->run() !== FALSE) {
			$component_array = array(
				'cmpny_id' => $companyID,
				'name' => $this->input->post('component_name'),
				'name_tr' => $this->input->post('component_name'),
				'active' => '1'
			);
			$component_id = $this->component_model->set_cmpnnt($component_array);

			$cmpny_flow_cmpnnt = array(
				'cmpny_flow_id' => $this->input->post('flowtype'),
				'description' => $this->input->post('description'),
				'qntty' => $this->sifirla($this->input->post('quantity')),
				'qntty_unit_id' => $this->sifirla($this->input->post('quantityUnit')),
				'supply_cost' => $this->sifirla($this->input->post('cost')),
				'supply_cost_unit' => $this->input->post('costUnit'),
				'output_cost' => $this->sifirla($this->input->post('ocost')),
				'output_cost_unit' => $this->input->post('ocostunit'),
				'data_quality' => $this->input->post('quality'),
				'substitute_potential' => $this->input->post('spot'),
				'comment' => $this->input->post('comment'),
				'cmpnt_type_id' =>$this->sifirla($this->input->post('component_type')),
				'cmpnnt_id' => $component_id
			);
			$this->component_model->set_cmpny_flow_cmpnnt($cmpny_flow_cmpnnt);
		}

		$data['units'] = $this->flow_model->get_unit_list();
		$data['component_name'] = $this->component_model->get_cmpnnt($companyID);
		$data['ctypes'] = $this->component_model->get_cmpnnt_type();
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['flow_and_flow_type'] = $this->component_model->get_cmpny_flow_and_flow_type($companyID);

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/new_component',$data);
		$this->load->view('template/footer');
	}

	public function edit_component($companyID,$id){

		$this->form_validation->set_rules('component_name', 'Component Name', 'trim|required|xss_clean');

		if($this->form_validation->run() !== FALSE) {
			$component_array = array(
				'name' => $this->input->post('component_name'),
				'name_tr' => $this->input->post('component_name'),
			);
			$component_id = $this->component_model->update_cmpnnt($component_array,$id,$companyID);

			$cmpny_flow_cmpnnt = array(
				'description' => $this->input->post('description'),
				'qntty' => $this->sifirla($this->input->post('quantity')),
				'qntty_unit_id' => $this->sifirla($this->input->post('quantityUnit')),
				'supply_cost' => $this->sifirla($this->input->post('cost')),
				'supply_cost_unit' => $this->input->post('costUnit'),
				'output_cost' => $this->sifirla($this->input->post('ocost')),
				'output_cost_unit' => $this->input->post('ocostunit'),
				'data_quality' => $this->input->post('quality'),
				'substitute_potential' => $this->input->post('spot'),
				'comment' => $this->input->post('comment'),
				'cmpnt_type_id' =>$this->sifirla($this->input->post('component_type')),
			);
			$this->component_model->update_cmpny_flow_cmpnnt($cmpny_flow_cmpnnt,$id);
			redirect('new_component/'.$companyID, 'refresh');
		}

		$data['component'] = $this->component_model->get_cmpnnt_info($companyID,$id);
		$data['units'] = $this->flow_model->get_unit_list();
		$data['ctypes'] = $this->component_model->get_cmpnnt_type();
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);

		$this->load->view('template/header');
		$this->load->view('dataset/edit_component',$data);
		$this->load->view('template/footer');
	}

	public function new_process($companyID){
		$this->form_validation->set_rules('process','Process','required');
		$this->form_validation->set_rules('usedFlows','Used Flows','required');

		// $this->form_validation->set_rules('min_rate_util','Minimum rate of utilization','trim|numeric|xss_clean');
		// $this->form_validation->set_rules('typ_rate_util','Typical rate of utilization','trim|numeric|xss_clean');
		// $this->form_validation->set_rules('max_rate_util','Maximum rate of utilization','trim|numeric|xss_clean');
		$this->form_validation->set_rules('comment','Comment','trim|xss_clean');


		if ($this->form_validation->run() !== FALSE)
		{
			$used_flows = $this->input->post('usedFlows');
			$process_id = $this->input->post('process');
			$processfamilyID = $this->input->post('processfamily');

			//CHECK IF PROCESS IS NEW?
			$process_id = $this->process_model->is_new_process($process_id,$processfamilyID);

			$cmpny_prcss_id = $this->process_model->can_write_cmpny_prcss($companyID,$process_id);

			if($cmpny_prcss_id == false){
				$cmpny_prcss = array(
					'cmpny_id' => $companyID,
					// 'min_rate_util' => $this->sifirla($this->input->post('min_rate_util')),
					// 'min_rate_util_unit' => $this->sifirla($this->input->post('min_rate_util_unit')),
					// 'typ_rate_util' => $this->sifirla($this->input->post('typ_rate_util')),
					// 'typ_rate_util_unit' => $this->sifirla($this->input->post('typ_rate_util_unit')),
					// 'max_rate_util' => $this->sifirla($this->input->post('max_rate_util')),
					// 'max_rate_util_unit' => $this->sifirla($this->input->post('max_rate_util_unit')),
					'comment' => $this->input->post('comment'),
					'prcss_id' => $process_id
				);
				$cmpny_prcss_id['id'] = $this->process_model->cmpny_prcss($cmpny_prcss);
			}

				if($this->process_model->can_write_cmpny_flow_prcss($used_flows,$cmpny_prcss_id['id']) == true){
					$cmpny_flow_prcss = array(
						'cmpny_flow_id' => $used_flows,
						'cmpny_prcss_id' => $cmpny_prcss_id['id']
					);
					$this->process_model->cmpny_flow_prcss($cmpny_flow_prcss);
			}
		}

		$data['process'] = $this->process_model->get_main_process();
		$data['company_flows']=$this->flow_model->get_company_flow_list($companyID);
		$data['cmpny_flow_prcss'] = $this->process_model->get_cmpny_flow_prcss($companyID);
		$data['cmpny_flow_prcss_count'] = array_count_values(array_column($data['cmpny_flow_prcss'], 'prcessname'));


		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['processfamilys'] = $this->process_model->get_processfamily_list();
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/new_process',$data);
		$this->load->view('template/footer');
	}

	public function edit_process($companyID,$process_id){

		// $this->form_validation->set_rules('min_rate_util','Minimum rate of utilization','trim|numeric|xss_clean');
		// $this->form_validation->set_rules('typ_rate_util','Typical rate of utilization','trim|numeric|xss_clean');
		// $this->form_validation->set_rules('max_rate_util','Maximum rate of utilization','trim|numeric|xss_clean');
		$this->form_validation->set_rules('comment','Comment','trim|xss_clean');

		if ($this->form_validation->run() !== FALSE)
		{
			//cant change flow and process since they affect other tables on database and also need lots of control for now.
			$cmpny_prcss = array(
				// 'min_rate_util' => $this->sifirla($this->input->post('min_rate_util')),
				// 'min_rate_util_unit' => $this->sifirla($this->input->post('min_rate_util_unit')),
				// 'typ_rate_util' => $this->sifirla($this->input->post('typ_rate_util')),
				// 'typ_rate_util_unit' => $this->sifirla($this->input->post('typ_rate_util_unit')),
				// 'max_rate_util' => $this->sifirla($this->input->post('max_rate_util')),
				// 'max_rate_util_unit' => $this->sifirla($this->input->post('max_rate_util_unit')),
				'comment' => $this->input->post('comment'),
			);
			$this->process_model->update_cmpny_flow_prcss($companyID,$process_id,$cmpny_prcss);
			redirect(base_url('new_process/'.$companyID), 'refresh');
		}

		$data['process'] = $this->process_model->get_cmpny_prcss_from_rid($companyID,$process_id);
		$data['companyID'] = $companyID;
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/edit_process',$data);
		$this->load->view('template/footer');
	}

	public function new_equipment($companyID){

		$this->form_validation->set_rules('usedprocess','Used Process','required');
		$this->form_validation->set_rules('equipment','Equipment Name','required');
		$this->form_validation->set_rules('equipmentTypeName','Equipment Type Name','required');
		$this->form_validation->set_rules('equipmentAttributeName','Equipment Attribute Name','required');
		$this->form_validation->set_rules('eqpmnt_attrbt_val','Equipment Attribute Value','trim|required|numeric|xss_clean');
		$this->form_validation->set_rules('eqpmnt_attrbt_unit','Equipment Attribute Unit','required|numeric');

		if ($this->form_validation->run() !== FALSE)
		{
			$prcss_id = $this->input->post('usedprocess');
			$equipment_id = $this->input->post('equipment');
			$equipment_type_id = $this->input->post('equipmentTypeName');
			$equipment_type_attribute_id = $this->input->post('equipmentAttributeName');
			$eqpmnt_attrbt_val = $this->input->post('eqpmnt_attrbt_val');
			$eqpmnt_attrbt_unit = $this->input->post('eqpmnt_attrbt_unit');

			$cmpny_eqpmnt_type_attrbt = array(
					'cmpny_id' => $companyID,
					'eqpmnt_id' => $equipment_id,
					'eqpmnt_type_id' => $equipment_type_id,
					'eqpmnt_type_attrbt_id' => $equipment_type_attribute_id,
					'eqpmnt_attrbt_val' => $eqpmnt_attrbt_val,
					'eqpmnt_attrbt_unit' => $eqpmnt_attrbt_unit
				);
			$last_index = $this->equipment_model->set_info($cmpny_eqpmnt_type_attrbt);

			$cmpny_prcss_id = $this->equipment_model->get_cmpny_prcss_id($companyID,$prcss_id);

			$cmpny_prcss = array(
					'cmpny_eqpmnt_type_id' => $last_index,
					'cmpny_prcss_id' => $cmpny_prcss_id['id']
				);
			$this->equipment_model->set_cmpny_prcss($cmpny_prcss);
		}

		$data['companyID'] = $companyID;
		$data['equipmentName'] = $this->equipment_model->get_equipment_name();
		$data['process'] = $this->equipment_model->cmpny_prcss($companyID);
		$data['informations'] = $this->equipment_model->all_information_of_equipment($companyID);
		$data['company_info'] = $this->company_model->get_company($companyID);
		$data['units'] = $this->flow_model->get_unit_list();

		$this->load->view('template/header');
		$this->load->view('dataset/dataSetLeftSide',$data);
		$this->load->view('dataset/new_equipment',$data);
		$this->load->view('template/footer');
	}

	public function delete_product($companyID,$id){
		$this->product_model->delete_product($id);
		redirect('new_product/'.$companyID, 'refresh');
	}
	public function delete_flow($companyID,$id){
		$cmpny_flow_prcss_id_list = $this->process_model->cmpny_flow_prcss_id_list($id);
		$this->process_model->delete_cmpny_flow_process($id);

		foreach ($cmpny_flow_prcss_id_list as $cmpny_flow_prcss_id) {
			if(!$this->process_model->still_exist_this_cmpny_prcss($cmpny_flow_prcss_id['cmpny_prcss_id'])){
				$this->equipment_model->delete_cmpny_equipment($cmpny_flow_prcss_id['cmpny_prcss_id']);
				$this->process_model->delete_cmpny_process($cmpny_flow_prcss_id['cmpny_prcss_id']);
			}
		}

		$this->component_model->delete_flow_cmpnnt_by_flowID($id);
		$this->flow_model->delete_flow($id);
		redirect('new_flow/'.$companyID, 'refresh');
	}

	public function delete_component($companyID,$id){
		$this->component_model->delete_flow_cmpnnt_by_cmpnntID($id);
		$this->component_model->delete_cmpnnt($companyID,$id);
		redirect('new_component/'.$companyID, 'refresh');
	}

	public function get_equipment_type(){
		$equipment_id = $this->input->post('equipment_id');
		$type_list = $this->equipment_model->get_equipment_type_list($equipment_id);
		echo json_encode($type_list);
	}

	public function get_equipment_attribute(){
		$equipment_type_id = $this->input->post('equipment_type_id');
		$attribute_list = $this->equipment_model->get_equipment_attribute_list($equipment_type_id);
		echo json_encode($attribute_list);
	}

	public function get_sub_process(){
		$processID = $this->input->post('processID');
		$process_list = $this->process_model->get_process_from_motherID($processID);
		echo json_encode($process_list);
	}

	// returns flowname user matchup for ajax.
	public function my_ep_values($flowname,$userid){
		$epvalue=$this->flow_model->get_My_Ep_Values($flowname,$userid);
		echo json_encode($epvalue);
	}

	// REFFNET UBP values
	public function UBP_values(){
		//todo only users with permission/licenese should be able to get the UBP value

		//checks permissions, if not loged in a redirect happens
		$user = $session->get('user_in');
		if(empty($user)){
			redirect('', 'refresh');
		}

		//All users can have their own imported / created UBP Data
		$data['userepvalues'] = $this->flow_model->get_userep($user['id']);

		//if they have UBP data they are shown, else they get an info in the miller 
		if (!empty($data['userepvalues'])) {
			$obj[] = array(
				'Einheit' => null,
				'DbId' => 000,
				'Name' => "My own UBP values",
				'Nr' => 1000,
				'ParentNr' => -1,
				'UbpPerEinheit' => -1,
				'VersionNr' => "v2"
			);

			$i = 1001; 
			foreach ($data['userepvalues'] as $epvalue) {
				
				$obj[] = array(
					'Einheit' => $epvalue['qntty_unit_name'],
					'DbId' => $epvalue['primary_id'],
					'Name' => $epvalue['flow_name'],
					'Nr' => $i,
					'ParentNr' => 1000,
					'UbpPerEinheit'=> $epvalue['ep_value'],
					'VersionNr'=> "v2"
				);
				$i++; 
			}

			$json = $obj;
		}
		else {
			$obj[] = array(
				'Einheit' => null,
				'DbId' => 000,
				'Name' => "My own UBP values",
				'Nr' => 1000,
				'ParentNr' => -1,
				'UbpPerEinheit' => -1.0,
				'VersionNr' => "v2"
			);

			$obj[] = array(
				'Einheit' => -1,
				'DbId' => 000,
				'Name' => 'You dont have entered any UBP values yet. Please go to "My EP Data" and add or import values.',
				'Nr' => 0,
				'ParentNr' => 1000,
				'UbpPerEinheit'=> -1.0,
				'VersionNr'=> "v2"
			);

			$json = $obj;
		}


		$is_consultant = $this->user_model->is_user_consultant($user['id']);
		//only consultants get UBP data (needs to be even stricter in future!)
		if ($is_consultant) {
			$url = 'https://reffnetservice.azurewebsites.net/api/LCA/GetAll?parentNr=500&token=TOKEN';

			//Use file_get_contents to GET the URL in question.
			$contents = file_get_contents($url);

			//Decodes json to check if the UBP data is array and object and to merge if it is possible
			//Decodes contents
			$json_EBP = json_decode($contents, true);
			
			//if contents is not json do error handling  
			if( !is_object($json_EBP) && !is_array($json_EBP)) {
				//TODO Error handling
			}
			else {
				//merges both arrays (from EBP and from EP import)
				$json = array_merge($json_EBP, $obj);	
			}
		}

		#sorts the json by its name values ascending (a to z)
	    usort($json, function($a, $b) {
	        return $a['Name'] <=> $b['Name'];
	    });

		//If $contents is not a boolean FALSE value.
		if(!empty($json)){
		    //Print out the contents.
		    echo json_encode($json);
		}
		else {
			echo "UBP access failed"; // todo if get json failed, send error
		}
		
	}

	public function delete_process($companyID,$company_process_id,$company_flow_id){

		$this->process_model->delete_company_flow_prcss($company_process_id,$company_flow_id);

		if(!$this->process_model->still_exist_this_cmpny_prcss($company_process_id))
		{
			$this->equipment_model->delete_cmpny_equipment($company_process_id);
			$this->process_model->delete_cmpny_process($company_process_id);
			//deletes allocations that are based on this process
			$this->cpscoping_model->delete_allocation_prcssid($company_process_id);
		}
		redirect('new_process/'.$companyID);
	}

	public function delete_equipment($cmpny_id,$cmpny_eqpmnt_id){

		$this->equipment_model->delete_cmpny_prcss_eqpmnt_type($cmpny_eqpmnt_id);
		$this->equipment_model->delete_cmpny_eqpmnt($cmpny_eqpmnt_id);
		redirect('new_equipment/'.$cmpny_id,'refresh');
	}

	/**
	 * For excel import to db. CBA EP values insertion for users. Just an excel read function for test
	 */
	public function excelread(){
		//this is just for test
		$file = './assets/excel/test.xlsx';
 
		//load the excel library
		$this->load->library('excel');
		 
		//read file from path
		$objPHPExcel = PHPExcel_IOFactory::load($file);
		 
		//get only the Cell Collection
		$cell_collection = $objPHPExcel->getActiveSheet()->getCellCollection();
		 
		//extract to a PHP readable array format
		foreach ($cell_collection as $cell) {
		    $column = $objPHPExcel->getActiveSheet()->getCell($cell)->getColumn();
		    $row = $objPHPExcel->getActiveSheet()->getCell($cell)->getRow();
		    $data_value = $objPHPExcel->getActiveSheet()->getCell($cell)->getValue();
		 
		    //header will/should be in row 1 only. of course this can be modified to suit your need.
		    if ($row == 1) {
		        $header[$row][$column] = $data_value;
		    } else {
		        $arr_data[$row][$column] = $data_value;
		    }
		}
		 
		//send the data in an array format
		$data['header'] = $header;
		$data['values'] = $arr_data;

		// insert to db
		// $this->user_model->create_dataset_for_users($data);

		//we will call views in here and show it


	}



}
