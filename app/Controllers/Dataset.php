<?php

namespace App\Controllers;

use App\Models\Product_model;
use App\Models\User_model;
use App\Models\Company_model;
use App\Models\Flow_model;
use App\Models\Process_model;
use App\Models\Equipment_model;
use App\Models\Component_model;

class Dataset extends BaseController {


	function sifirla($data){
		if(empty($data)) return 0;
		else return $data;
	}

	public function new_product($companyID)
	{
		$product_model = model(Product_model::class);
		$flow_model = model(Flow_model::class);
		$company_model = model(Company_model::class);

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'product'=>  'trim|required',
				'quantities'=>  'trim|numeric',
				'ucost'=> 'trim|numeric',
				'ucostu'=>'trim',
				'qunit'=> 'trim',
				'tper'=> 'trim'
			]))
			{
				$productArray = array(
						'cmpny_id' => $companyID,
						'name' => $this->request->getPost('product'),
						'quantities' => $this->sifirla($this->request->getPost('quantities')),
						'ucost' => $this->sifirla($this->request->getPost('ucost')),
						'ucostu' => $this->request->getPost('ucostu'),
						'qunit' => $this->request->getPost('qunit'),
						'tper' => $this->request->getPost('tper'),
					);
				$product_model->set_product($productArray);
			}
		}

		$data['validation'] = $this->validator;
		$data['product'] = $product_model->get_product_list($companyID);
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['units'] = $flow_model->get_unit_list();

		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/new_product',$data);
		echo view('template/footer');
	}

	public function edit_product($companyID,$product_id)
	{
		$product_model = model(Product_model::class);
		$flow_model = model(Flow_model::class);
		$company_model = model(Company_model::class);
		
		if(!empty($this->request->getPost())){
			if ($this->validate([
				'product' 		=> 'trim|required',
				'quantities'	=>  'trim|numeric',
				'ucost'			=>  'trim|numeric',
				'ucostu'		=>  'trim',
				'qunit'			=>  'trim',
				'tper' 		 	=>  'trim'
			]))
			{
				$productArray = array(
						'cmpny_id' => $companyID,
						'name' => $this->request->getPost('product'),
						'quantities' => $this->sifirla($this->request->getPost('quantities')),
						'ucost' => $this->sifirla($this->request->getPost('ucost')),
						'ucostu' => $this->request->getPost('ucostu'),
						'qunit' => $this->request->getPost('qunit'),
						'tper' => $this->request->getPost('tper'),
					);
				$product_model->update_product($companyID,$product_id,$productArray);
				return redirect()->to('new_product/'.$companyID);
			}
		}
		
		$data['validation'] = $this->validator;
		$data['product'] = $product_model->get_product_by_cid_pid($companyID,$product_id);
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['units'] = $flow_model->get_unit_list();

		echo view('template/header');
		echo view('dataset/edit_product',$data);
		echo view('template/footer');
	}

	public function new_flow($companyID)
	{
		$process_model = model(Process_model::class);
		$flow_model = model(Flow_model::class);
		$company_model = model(Company_model::class);

		//checks permissions, if not loged in a redirect happens
		$user = $this->session->username;
		if(empty($user)){
			return redirect()->to(site_url(''));
		}

		$data['flownames'] = $flow_model->get_flowname_list();

		if (!empty($this->request->getPost())){
			if ($this->validate([
				'flowname' => 'trim|required|strip_tags',
				'flowtype' => 'trim|required|strip_tags',
				'quantity' => "trim|required|strip_tags|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]|max_length[8]",
				'quantityUnit' => 'trim|required|strip_tags',
				'cost' =>  "trim|required|strip_tags|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]|max_length[8]",
				'costUnit' =>  'trim|required|strip_tags',
				'ep' =>  "trim|strip_tags|max_length[25]|regex_match[/^(\d+|\d{1,3}('\d{3})*)((\,|\.)\d+)?$/]",
				'epUnit' => 'trim|strip_tags',
				'charactertype' =>  'trim|strip_tags|max_length[50]',
				'availability' =>  'trim',
				'cf' =>  'trim|max_length[30]',
				'state' =>  'trim',
				'quality' =>  'trim|max_length[150]',
				'oloc' =>  'trim',
				'spot' =>  'trim',
				'desc' =>  'trim|max_length[500]',
				'comment' =>  'trim'
			])){


				//do we need to replace spaces with _ anymore? str_replace(' ', '_', $variable);
				$flowID = $this->request->getPost('flowname');
				//and make it to lower case? Its anyway predefined right now
				//$flowID = strtolower($flowID);

				//if the flow already exists the id is used, 
				// other wise the name is used an new flow enty is created with is_new_flow($flowID,$flowfamilyID);
				foreach ($data['flownames'] as $flowname) {
					if ($flowID == $flowname['name']) {
						$flowID = $flowname['id'];
					}
				}


				$charactertype = $this->request->getPost('charactertype');
				$flowtypeID = $this->request->getPost('flowtype');
				$flowfamilyID = $this->request->getPost('flowfamily');

				//checks if flow already exist (as input OR output), same as flow_varmi()
				$uri = service('uri');

				$companyID = $uri->getSegment(2);
				if(is_numeric($flowID)){
					if(!$flow_model->has_same_flow($flowID,$flowtypeID,$companyID)){
						$this->session->set_flashdata('message', 'Flow can only be added twice (as input and output), please check your flows.');
						//print_r("false");
						return redirect()->back();
					}
				}

				//CHECKs IF FLOW IS NEW (old flows have their IDs)
				$flowID = $process_model->is_new_flow($flowID,$flowfamilyID);

				#EP input field: By regex_match , . and ' are allowed.
				#this replaces , with . and removes thousand separator ' to store numeric in DB later
				$ep = $this->numeric_input_formater($this->request->getPost('ep'));
				$epUnit = $this->request->getPost('epUnit');

				#Cost input field: By regex_match , . and ' are allowed.
				#this replaces , with . and removes thousand separator ' to store numeric in DB later
				$cost = $this->numeric_input_formater($this->request->getPost('cost'));
				$costUnit = $this->request->getPost('costUnit');

				#Quantity input field: By regex_match , . and ' are allowed.
				#this replaces , with . and removes thousand separator ' to store numeric in DB later
				$quantity = $this->numeric_input_formater($this->request->getPost('quantity'));
				$quantityUnit = $this->request->getPost('quantityUnit');

				$data['units'] = $flow_model->get_unit_list();
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
				
				$cf = $this->request->getPost('cf');
				$availability = $this->request->getPost('availability');
				$conc = $this->request->getPost('conc');
				$concunit = $this->request->getPost('concunit');
				$pres = $this->request->getPost('pres');
				$presunit = $this->request->getPost('presunit');
				$ph = $this->request->getPost('ph');
				$state = $this->request->getPost('state');
				$quality = $this->request->getPost('quality');
				$oloc = $this->request->getPost('oloc');
				$desc = $this->request->getPost('desc');
				$spot = $this->request->getPost('spot');
				$comment = $this->request->getPost('comment');

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

				$flow_model->register_flow_to_company($flow);
			}

		}

		$data['flowtypes'] = $flow_model->get_flowtype_list();
		$data['flowfamilys'] = $flow_model->get_flowfamily_list();
		$data['company_flows']=$flow_model->get_company_flow_list($companyID);
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['validation'] = $this->validator;


		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/new_flow',$data);
		echo view('template/footer');

	}

	public function edit_flow($companyID,$flow_id,$flow_type_id)
	{
		$flow_model = model(Flow_model::class);
		$company_model = model(Company_model::class);

		if (!empty($this->request->getPost())){
			if ($this->validate([
				'quantity'=> 'trim|required|strip_tags|numeric',
				'quantityUnit'=> 'trim|required|strip_tags',
				'cost'=> 'trim|required|strip_tags|numeric',
				'costUnit'=> 'trim|required|strip_tags',
				'ep'=> 'trim|strip_tags|numeric',
				'epUnit'=> 'trim|strip_tags',
				'charactertype'=> 'trim|strip_tags|max_length[50]',
				'availability'=> 'trim',
				'cf'=> 'trim|max_length[100]',
				'state'=> 'trim',
				'quality'=> 'trim|max_length[150]',
				'oloc'=> 'trim',
				'spot'=> 'trim',
				'desc'=> 'trim|max_length[500]',
				'comment'=> 'trim'
			])){

			$charactertype = $this->request->getPost('charactertype');
			$ep = $this->request->getPost('ep');
			$epUnit = $this->request->getPost('epUnit');
			$cost = $this->request->getPost('cost');
			$costUnit = $this->request->getPost('costUnit');
			$quantity = $this->request->getPost('quantity');
			$quantityUnit = $this->request->getPost('quantityUnit');

			$cf = $this->request->getPost('cf');
			$availability = $this->request->getPost('availability');
			$conc = $this->request->getPost('conc');
			$concunit = $this->request->getPost('concunit');
			$pres = $this->request->getPost('pres');
			$presunit = $this->request->getPost('presunit');
			$ph = $this->request->getPost('ph');
			$state = $this->request->getPost('state');
			$quality = $this->request->getPost('quality');
			$oloc = $this->request->getPost('oloc');
			$desc = $this->request->getPost('desc');
			$spot = $this->request->getPost('spot');
			$comment = $this->request->getPost('comment');

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

			$flow_model->update_flow_info($companyID,$flow_id,$flow_type_id,$flow);
			return redirect()->to('new_flow/'.$companyID);

			}
		}

		$data['flow']=$flow_model->get_company_flow($companyID,$flow_id,$flow_type_id);
		if(empty($data['flow'])){
			return redirect()->to(site_url());
		}
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['units'] = $flow_model->get_unit_list();
		$data['validation'] = $this->validator;

		echo view('template/header');
		echo view('dataset/edit_flow',$data);
		echo view('template/footer');
	}

	function flow_varmi()
	{
		$uri = service('uri');

		$flow_model = model(Flow_model::class);
		$flowID = $this->request->getPost('flowname');
		$flowtypeID = $this->request->getPost('flowtype');
		$companyID = $uri->segment(2);
		if(is_numeric($flowID)){
			if(!$flow_model->has_same_flow($flowID,$flowtypeID,$companyID)){
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


	function numeric_input_formater($int)
	{
		#replaces , with . and thousand separator ' with nothing
		$int = str_replace(',', '.', $int);
		$int = str_replace("'", '', $int);
	  	return $int;
	}

	public function new_component($companyID){

		$component_model = model(Component_model::class);
		$company_model = model(Company_model::class);
		$flow_model = model(Flow_model::class);

		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		if(!empty($this->request->getPost())){

			if ($this->validate([
					'component_name'=> 'trim|required',
					'flowtype'=> 'trim'
				])){

					$component_array = array(
						'cmpny_id' => $companyID,
						'name' => $this->request->getPost('component_name'),
						'name_tr' => $this->request->getPost('component_name'),
						'active' => '1'
					);
					$component_id = $component_model->set_cmpnnt($component_array);

					$cmpny_flow_cmpnnt = array(
						'cmpny_flow_id' => $this->request->getPost('flowtype'),
						'description' => $this->request->getPost('description'),
						'qntty' => $this->sifirla($this->request->getPost('quantity')),
						'qntty_unit_id' => $this->sifirla($this->request->getPost('quantityUnit')),
						'supply_cost' => $this->sifirla($this->request->getPost('cost')),
						'supply_cost_unit' => $this->request->getPost('costUnit'),
						'output_cost' => $this->sifirla($this->request->getPost('ocost')),
						'output_cost_unit' => $this->request->getPost('ocostunit'),
						'data_quality' => $this->request->getPost('quality'),
						'substitute_potential' => $this->request->getPost('spot'),
						'comment' => $this->request->getPost('comment'),
						'cmpnt_type_id' =>$this->sifirla($this->request->getPost('component_type')),
						'cmpnnt_id' => $component_id
					);
					$component_model->set_cmpny_flow_cmpnnt($cmpny_flow_cmpnnt);
				}
		}
		$data['units'] = $flow_model->get_unit_list();
		$data['component_name'] = $component_model->get_cmpnnt($companyID);
		$data['ctypes'] = $component_model->get_cmpnnt_type();
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['flow_and_flow_type'] = $component_model->get_cmpny_flow_and_flow_type($companyID);
		$data['validation'] = $this->validator;

		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/new_component',$data);
		echo view('template/footer');
	}

	public function edit_component($companyID,$id){

		$component_model = model(Component_model::class);
		$company_model = model(Company_model::class);
		$flow_model = model(Flow_model::class);

		if(!empty($this->request->getPost())){
			if ($this->validate([
					'component_name'=> 'trim|required'
				])){

				$component_array = array(
					'name' => $this->request->getPost('component_name'),
					'name_tr' => $this->request->getPost('component_name'),
				);
				$component_id = $component_model->update_cmpnnt($component_array,$id,$companyID);

				$cmpny_flow_cmpnnt = array(
					'description' => $this->request->getPost('description'),
					'qntty' => $this->sifirla($this->request->getPost('quantity')),
					'qntty_unit_id' => $this->sifirla($this->request->getPost('quantityUnit')),
					'supply_cost' => $this->sifirla($this->request->getPost('cost')),
					'supply_cost_unit' => $this->request->getPost('costUnit'),
					'output_cost' => $this->sifirla($this->request->getPost('ocost')),
					'output_cost_unit' => $this->request->getPost('ocostunit'),
					'data_quality' => $this->request->getPost('quality'),
					'substitute_potential' => $this->request->getPost('spot'),
					'comment' => $this->request->getPost('comment'),
					'cmpnt_type_id' =>$this->sifirla($this->request->getPost('component_type')),
				);
				$component_model->update_cmpny_flow_cmpnnt($cmpny_flow_cmpnnt,$id);
				return redirect()->to(site_url('new_component/'.$companyID));
			}
		}

		$data['validation'] = $this->validator;
		$data['component'] = $component_model->get_cmpnnt_info($companyID,$id);
		$data['units'] = $flow_model->get_unit_list();
		$data['ctypes'] = $component_model->get_cmpnnt_type();
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);

		echo view('template/header');
		echo view('dataset/edit_component',$data);
		echo view('template/footer');
	}

	public function new_process($companyID){

		$flow_model = model(Flow_model::class);
		$process_model = model(Process_model::class);
		$company_model = model(Company_model::class);

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'process'=>'required',
				'usedFlows'=>'required',
				'comment'=>'trim'
			]))
			{
				$used_flows = $this->request->getPost('usedFlows');
				$process_id = $this->request->getPost('process');
				$processfamilyID = $this->request->getPost('processfamily');

				//CHECK IF PROCESS IS NEW?
				$process_id = $process_model->is_new_process($process_id,$processfamilyID);
				$cmpny_prcss_id = $process_model->can_write_cmpny_prcss($companyID,$process_id);

					if($cmpny_prcss_id == false){
						$cmpny_prcss = array(
							'cmpny_id' => $companyID,
							'comment' => $this->request->getPost('comment'),
							'prcss_id' => $process_id
						);
						$cmpny_prcss_id['id'] = $process_model->cmpny_prcss($cmpny_prcss);
					}
					if($process_model->can_write_cmpny_flow_prcss($used_flows,$cmpny_prcss_id['id']) == true){
						$cmpny_flow_prcss = array(
							'cmpny_flow_id' => $used_flows,
							'cmpny_prcss_id' => $cmpny_prcss_id['id']
						);
					$process_model->cmpny_flow_prcss($cmpny_flow_prcss);
				}
			}
		}

		$data['validation'] = $this->validator;
		$data['process'] = $process_model->get_main_process();
		$data['company_flows']=$flow_model->get_company_flow_list($companyID);
		$data['cmpny_flow_prcss'] = $process_model->get_cmpny_flow_prcss($companyID);
		$data['cmpny_flow_prcss_count'] = array_count_values(array_column($data['cmpny_flow_prcss'], 'prcessname'));
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['processfamilys'] = $process_model->get_processfamily_list();
		$data['units'] = $flow_model->get_unit_list();

		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/new_process',$data);
		echo view('template/footer');
	}

	public function edit_process($companyID,$process_id){

		$flow_model = model(Flow_model::class);
		$process_model = model(Process_model::class);
		$company_model = model(Company_model::class);
	
		if(!empty($this->request->getPost())){
			if ($this->validate([
				'comment'=>'trim|required',
			]))
			{
				//cant change flow and process since they affect other tables on database and also need lots of control for now.
				$cmpny_prcss = array(
					'comment' => $this->request->getPost('comment'),
				);
				$process_model->update_cmpny_flow_prcss($companyID,$process_id,$cmpny_prcss);
				return redirect()->to('new_process/'.$companyID);
			}
		}

		$data['validation'] = $this->validator;
		$data['process'] = $process_model->get_cmpny_prcss_from_rid($companyID,$process_id);
		$data['companyID'] = $companyID;
		$data['company_info'] = $company_model->get_company($companyID);
		$data['units'] = $flow_model->get_unit_list();

		echo view('template/header');
		echo view('dataset/edit_process',$data);
		echo view('template/footer');
	}

	public function new_equipment($companyID){

		$equipment_model = model(Equipment_model::class);
		$company_model = model(Company_model::class);
		$flow_model = model(Flow_model::class);

		if(!empty($this->request->getPost())){
			if ($this->validate([
				'usedprocess'  => 'required',
				'equipment'  => 'required',
				'equipmentTypeName'  => 'required',
				'equipmentAttributeName'  => 'required',
				'eqpmnt_attrbt_val'  => 'trim|required|numeric',
				'eqpmnt_attrbt_unit'  => 'required|numeric'
			]))
			{
				$prcss_id = $this->request->getPost('usedprocess');
				$equipment_id = $this->request->getPost('equipment');
				$equipment_type_id = $this->request->getPost('equipmentTypeName');
				$equipment_type_attribute_id = $this->request->getPost('equipmentAttributeName');
				$eqpmnt_attrbt_val = $this->request->getPost('eqpmnt_attrbt_val');
				$eqpmnt_attrbt_unit = $this->request->getPost('eqpmnt_attrbt_unit');

				$cmpny_eqpmnt_type_attrbt = array(
						'cmpny_id' => $companyID,
						'eqpmnt_id' => $equipment_id,
						'eqpmnt_type_id' => $equipment_type_id,
						'eqpmnt_type_attrbt_id' => $equipment_type_attribute_id,
						'eqpmnt_attrbt_val' => $eqpmnt_attrbt_val,
						'eqpmnt_attrbt_unit' => $eqpmnt_attrbt_unit
					);

				$last_index = $equipment_model->set_info($cmpny_eqpmnt_type_attrbt);
				$cmpny_prcss_id = $equipment_model->get_cmpny_prcss_id($companyID,$prcss_id);
				$cmpny_prcss = array(
						'cmpny_eqpmnt_type_id' => $last_index,
						'cmpny_prcss_id' => $cmpny_prcss_id['id']
					);
				$equipment_model->set_cmpny_prcss($cmpny_prcss);
			}
		}

		$data['validation'] = $this->validator;
		$data['companyID'] = $companyID;
		$data['equipmentName'] = $equipment_model->get_equipment_name();
		$data['process'] = $equipment_model->cmpny_prcss($companyID);
		$data['informations'] = $equipment_model->all_information_of_equipment($companyID);
		$data['company_info'] = $company_model->get_company($companyID);
		$data['units'] = $flow_model->get_unit_list();

		echo view('template/header');
		echo view('dataset/dataSetLeftSide',$data);
		echo view('dataset/new_equipment',$data);
		echo view('template/footer');
	}

	public function delete_product($companyID,$id){
		$product_model = model(Product_model::class);
		$product_model->delete_product($id);
		return redirect()->to(site_url('new_product/'.$companyID));
	}

	public function delete_flow($companyID,$id){
		$process_model = model(Process_model::class);
		$equipment_model = model(Equipment_model::class);
		$flow_model = model(Flow_model::class);
		$component_model = model(Component_model::class);

		$cmpny_flow_prcss_id_list = $process_model->cmpny_flow_prcss_id_list($id);
		$process_model->delete_cmpny_flow_process($id);

		foreach ($cmpny_flow_prcss_id_list as $cmpny_flow_prcss_id) {
			if(!$process_model->still_exist_this_cmpny_prcss($cmpny_flow_prcss_id['cmpny_prcss_id'])){
				$equipment_model->delete_cmpny_equipment($cmpny_flow_prcss_id['cmpny_prcss_id']);
				$process_model->delete_cmpny_process($cmpny_flow_prcss_id['cmpny_prcss_id']);
			}
		}

		$component_model->delete_flow_cmpnnt_by_flowID($id);
		$flow_model->delete_flow($id);
		return redirect()->to(site_url('new_flow/'.$companyID));
	}

	public function delete_component($companyID,$id){
		$component_model = model(Component_model::class);
		$component_model->delete_flow_cmpnnt_by_cmpnntID($id);
		$component_model->delete_cmpnnt($companyID,$id);
		return redirect()->to(site_url('new_component/'.$companyID));
	}

	public function get_equipment_type(){
		$equipment_model = model(Equipment_model::class);
		$equipment_id = $this->request->getPost('equipment_id');
		$type_list = $equipment_model->get_equipment_type_list($equipment_id);
		echo json_encode($type_list);
	}

	public function get_equipment_attribute(){
		$equipment_model = model(Equipment_model::class);
		$equipment_type_id = $this->request->getPost('equipment_type_id');
		$attribute_list = $equipment_model->get_equipment_attribute_list($equipment_type_id);
		echo json_encode($attribute_list);
	}

	public function get_sub_process(){
		$process_model = model(Process_model::class);
		$processID = $this->request->getPost('processID');
		$process_list = $process_model->get_process_from_motherID($processID);
		echo json_encode($process_list);
	}

	// returns flowname user matchup for ajax.
	public function my_ep_values($flowname,$userid){
		$flow_model = model(Flow_model::class);
		$epvalue=$flow_model->get_My_Ep_Values($flowname,$userid);
		echo json_encode($epvalue);
	}

	// REFFNET UBP values
	public function UBP_values(){
		//todo only users with permission/licenese should be able to get the UBP value
		$flow_model = model(Flow_model::class);
		$user_model = model(User_model::class);

		if(empty($this->session->username)){
			return redirect()->to(site_url());
		}

		//All users can have their own imported / created UBP Data
		$data['userepvalues'] = $flow_model->get_userep($this->session->id);

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

		$is_consultant = $user_model->is_user_consultant($this->session->id);
		//only consultants get UBP data (needs to be even stricter in future!)
		if ($is_consultant == 1) {

			//$url = 'https://reffnetservice.azurewebsites.net/api/LCA/GetAll?parentNr=500&token='.$_ENV['TOKEN'];

			// concat directly is not really secure. Breaking it and concat it would be safer like here
			$url = 'https://reffnetservice.azurewebsites.net/api/LCA/GetAll';
			$queryParams = [
				'parentNr' => 500,
				'token' => 'TOKEN'
			];			

			$url .= '?'. http_build_query($queryParams);

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
			echo "UBP access failed";// todo if get json failed, send error
		}

	}
		else {
			echo "UBP access failed. You don't have correct permission to access the data"; // todo if not consultant, send error
		}
		
	}

	public function delete_process($companyID,$company_process_id,$company_flow_id){
		$process_model = model(Process_model::class);
		$equipment_model = model(Equipment_model::class);
		$cpscoping_model = model(Cpscoping_model::class);

		$process_model->delete_company_flow_prcss($company_process_id,$company_flow_id);

		if(!$process_model->still_exist_this_cmpny_prcss($company_process_id))
		{
			$equipment_model->delete_cmpny_equipment($company_process_id);
			$process_model->delete_cmpny_process($company_process_id);
			//deletes allocations that are based on this process
			$cpscoping_model->delete_allocation_prcssid($company_process_id);
		}
		return redirect()->to(site_url('new_process/'.$companyID));
	}

	public function delete_equipment($cmpny_id,$cmpny_eqpmnt_id){
		$equipment_model = model(Equipment_model::class);
		$equipment_model->delete_cmpny_prcss_eqpmnt_type($cmpny_eqpmnt_id);
		$equipment_model->delete_cmpny_eqpmnt($cmpny_eqpmnt_id);
		return redirect()->to(site_url('new_equipment/'.$cmpny_id));
	}

	/**
	 * For excel import to db. CBA EP values insertion for users. Just an excel read function for test
	 */
	public function excelread(){
		//this is just for test
		$file = './assets/excel/test.xlsx';
 
		// TODO: use composer require phpoffice/phpspreadsheet

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
