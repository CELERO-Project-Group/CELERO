<script src="https://d3js.org/d3.v3.min.js"></script>
<div class="col-md-12">
	<div class="lead"><?= $company['name']; ?></div>
<style type="text/css">
.tg  {border-collapse:collapse; border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:11px; padding:5px 5px; border-style:solid; border-width:1px; overflow:hidden;word-break:normal; color:#999;}
.tg th{font-family:Arial, sans-serif; text-align: right; font-size:11px; padding:5px 5px; border-style:solid;border-width:1px;overflow:hidden;word-break:normal; color:#000;font-weight: normal}
.tg .th-yw4l{font-weight: bold}
.tg .tg-yw4l{vertical-align:top;}
.tg .tg-yw4l input{font-size: 11px; height: 25px; text-align: right;}
.title_cb {border-collapse:collapse; border-spacing:0; width: 100%;}
.th-yw4l .option-start { }

.dropdowni {overflow:visible; position:relative;}
</style>
<?php  $allocation = array_merge($allocation, $is); ?>
	<p><?= lang("cbaheading"); ?></p>
	<?php if (!empty($allocation)): ?>
	<?php $i=1; ?>
	<?php foreach ($allocation as $a): ?>
        <!-- cp_or_is variable set based on available/empty $a['cp_id'] -->
        <?php if(!empty($a['cp_id'])){$iid=$a['cp_id']; $tip="cp";  $cp_or_is="cp";}else{$iid=$a['is_id'];$tip="is";  
            $cp_or_is="is";} ?>
        <!-- if no unit_cost is defined a "-" is placed!-->
		<?php if(empty($a['unit_cost'])){$a['unit_cost']="-";} ?>
        <!-- if no capexold is defined make it 0 (because its a numeric field in the DB, if empty = error!-->
        <?php if(empty($a['capexold'])){$a['capexold']=0;} ?>
		<?php $attributes = array('id' => 'form-'.$i); ?>
		<?= form_open('cba/save/'.$this->uri->segment(2).'/'.$this->uri->segment(3).'/'.$iid.'/'.$tip, $attributes); ?>
    <table class="tg costtable">
        <tr>
            <th colspan="9" style="font-size: 12px; text-align: left;">
                <b>
            <?php if(empty($a['cmpny_from_name'])) {echo $a['best'];} else {echo $a['flow_name']." input IS potential from/to ".$a['cmpny_from_name']; } ?>:
                </b> Baseline</th>
            <th colspan="20" style="font-size: 12px; border-left:2px solid grey; text-align: left;">Option</th>
        </tr>
        <tr>
            <th class="th-yw4l" bgcolor="#fefefc">CAPEX (<?= $a['unit_cost']; ?>/a)</th>
            <th class="th-yw4l" bgcolor="#fefefc" colspan="2">Annual energy and material flows</th>
            <th class="th-yw4l" bgcolor="#fefefc">unit</th>
            <th class="th-yw4l" bgcolor="#fefefc">Specific costs (<?= $a['unit_cost']; ?>/unit)</th>
            <th class="th-yw4l" bgcolor="#fefefc">OPEX (<?= $a['unit_cost']; ?>)</th>
            <th class="th-yw4l" bgcolor="#fefefc">EP/ Unit</th>
            <th class="th-yw4l" bgcolor="#fefefc">EP</th>
            <th class="th-yw4l" bgcolor="#fefefc">Annual costs (<?= $a['unit_cost']; ?>/a)</th>
            <th class="th-yw4l" bgcolor="#fdfdff" style="border-left:2px solid grey;">Lifetime (a)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Investment (<?= $a['unit_cost']; ?>)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Discount rate (%) </th>
            <th class="th-yw4l" bgcolor="#fdfdff">CAPEX (<?= $a['unit_cost']; ?>/a)</th>
            <th class="th-yw4l" bgcolor="#fdfdff" colspan="2">Annual energy and material flows</th>
            <th class="th-yw4l" bgcolor="#fdfdff">unit 
                <label class="tooltip-unit" data-toggle="tooltip">
                    <i style="color:red;" class="fa fa-question-circle"></i>
                </label>
            </th>
            <th class="th-yw4l" bgcolor="#fdfdff">Specific costs (<?= $a['unit_cost']; ?>/unit)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">OPEX (<?= $a['unit_cost']; ?>)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">EP/ Unit</th>
            <th class="th-yw4l" bgcolor="#fdfdff">EP</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Annual costs (<?= $a['unit_cost']; ?>/a)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Flow Name</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Differences of flows</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Unit</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Reduction OPEX (<?= $a['unit_cost']; ?>)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Economic Benefit (<?= $a['unit_cost']; ?>)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Ecological Benefit (EP)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Marginal costs (<?= $a['unit_cost']; ?>/EP)</th>
            <th class="th-yw4l" bgcolor="#fdfdff">Payback time (a)</th>
            <th class="th-yw4l" style=" text-align: center;">Save</th>
        </tr>
        <tr>
        <td class="tg-yw4l" rowspan="7">
        	<div class="  "><input type="text" name="capexold" id="capexold-<?= $i; ?>" class="form-control  " value="<?= $a['capexold']; ?>" placeholder="You should fill this field."></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1" id="flow-name-1-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1" id="flow-value-1-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1" id="flow-unit-1-<?= $i; ?>" class="form-control " value="<?= $a['flow-unit-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1" id="flow-specost-1-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1" id="flow-opex-1-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1" id="flow-eipunit-1-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1" id="flow-eip-1-<?= $i; ?>" class="form-control  " value="<?= $a['floweip-1']; ?>" placeholder="Fill"  ></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
            <div class="  "><input type="text" name="annual-cost-1" id="annual-cost-1-<?= $i; ?>" class="form-control  " value="<?= $a['annual-cost-1']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7" style="border-left:2px solid grey; ">
        	<div class="  "><input type="text" name="ltold" id="ltold-<?= $i; ?>" value="<?= $a['ltold']; ?>" class="form-control" placeholder="You should fill this field."></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
            <div class="  "><input type="text" name="investment" id="investment-<?= $i; ?>" value="<?= $a['investment']; ?>" class="form-control" placeholder="You should fill this field."></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
        	<div class="  "><input type="text" name="disrate" id="disrate-<?= $i; ?>"  value="<?= $a['disrate']; ?>" class="form-control" placeholder="You should fill this field."></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
        	<div class="  "><input type="text" name="capex-1" id="capex-1-<?= $i; ?>"  value="<?= $a['capex-1']; ?>" class="form-control" placeholder="capex-1" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2" id="flow-name-2-<?= $i; ?>"  value="<?= $a['flow-name-2']; ?>" class="form-control" placeholder="flow-name-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2" id="flow-value-2-<?= $i; ?>"  value="<?= $a['flow-value-2']; ?>" class="form-control" placeholder="flow-value-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2" id="flow-unit-2-<?= $i; ?>"  value="<?= $a['flow-unit-2']; ?>" class="form-control" placeholder="flow-unit-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2" id="flow-specost-2-<?= $i; ?>"  value="<?= $a['flow-specost-2']; ?>" class="form-control" placeholder="flow-specost-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2" id="flow-opex-2-<?= $i; ?>"  value="<?= $a['flow-opex-2']; ?>" class="form-control" placeholder="flow-opex-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2" id="flow-eipunit-2-<?= $i; ?>"  value="<?= $a['flow-eipunit-2']; ?>" class="form-control" placeholder="flow-eipunit-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2" id="flow-eip-2-<?= $i; ?>"  value="<?= $a['flow-eip-2']; ?>" class="form-control" placeholder="flow-eip-2" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
            <div class="  "><input type="text" name="annual-cost-2" id="annual-cost-2-<?= $i; ?>"  value="<?= $a['annual-cost-2']; ?>" class="form-control" placeholder="annual-cost-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3" id="flow-name-3-<?= $i; ?>"  value="<?= $a['flow-name-3']; ?>" class="form-control" placeholder="flow-name-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3" id="flow-value-3-<?= $i; ?>"  value="<?= $a['flow-value-3']; ?>" class="form-control" placeholder="flow-value-3" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3" id="flow-unit-3-<?= $i; ?>"  value="<?= $a['flow-unit-3']; ?>" class="form-control" placeholder="flow-unit-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3" id="flow-opex-3-<?= $i; ?>"  value="<?= $a['flow-opex-3']; ?>" class="form-control" placeholder="flow-opex-3" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7">            
            <div class="  "><input type="text" name="ecoben-1" id="ecoben-1-<?= $i; ?>"  value="<?= $a['ecoben-1']; ?>" class="form-control" placeholder="ecoben-1" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1" id="ecoben-eip-1-<?= $i; ?>"  value="<?= $a['ecoben-eip-1']; ?>" class="form-control" placeholder="ecoben-eip-1" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
            <div class="  "><input type="text" name="marcos-1" id="marcos-1-<?= $i; ?>"  value="<?= $a['marcos-1']; ?>" class="form-control" placeholder="marcos-1" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7">
            <div class="  "><input type="text" name="payback-1" id="payback-1-<?= $i; ?>"  value="<?= $a['payback-1']; ?>" class="form-control" placeholder="payback-1" ></div>
        </td>
        <td class="tg-yw4l" rowspan="7" style="vertical-align: middle;">
            <input type="submit" value="Save" class="btn btn-block btn-info" style="width: 100px; text-align: center;">
            <!-- cp_or_is variable posted hidden -->
            <input type="hidden" name="cp_or_is" value="<?= $cp_or_is ?>" >
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1-2" id="flow-name-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1-2']; ?>" placeholder="Fill or ...">
                <select name="flow_name" id="select-flow-1-2-<?= $i; ?>" onchange="insertFlowRow(this)" class="dropdown" style="overflow:visible; position:relative;">
                    <option value="">select flow</option>
                    <?php foreach ($allocated_flows as $flowname): ?>
                        <option value="<?= $flowname['allocation_id']; ?>"><?= $flowname['prcss_name'] .": ". $flowname['flow_name']; ?> (<?= $flowname['flow_type_name']; ?>)</option>
                    <?php endforeach ?>
                </select>
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1-2" id="flow-value-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1-2']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1-2" id="flow-unit-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-unit-1-2']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1-2" id="flow-specost-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1-2']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1-2" id="flow-opex-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1-2']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1-2" id="flow-eipunit-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1-2']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1-2" id="flow-eip-1-2-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eip-1-2']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2-2" id="flow-name-2-2-<?= $i; ?>"  value="<?= $a['flow-name-2-2']; ?>" class="form-control" placeholder="flow-name-2-2">
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2-2" id="flow-value-2-2-<?= $i; ?>"  value="<?= $a['flow-value-2-2']; ?>" class="form-control" placeholder="flow-value-2-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2-2" id="flow-unit-2-2-<?= $i; ?>"  value="<?= $a['flow-unit-2-2']; ?>" class="form-control" placeholder="flow-unit-2-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2-2" id="flow-specost-2-2-<?= $i; ?>"  value="<?= $a['flow-specost-2-2']; ?>" class="form-control" placeholder="flow-specost-2-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2-2" id="flow-opex-2-2-<?= $i; ?>"  value="<?= $a['flow-opex-2-2']; ?>" class="form-control" placeholder="flow-opex-2-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2-2" id="flow-eipunit-2-2-<?= $i; ?>"  value="<?= $a['flow-eipunit-2-2']; ?>" class="form-control" placeholder="flow-eipunit-2-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2-2" id="flow-eip-2-2-<?= $i; ?>"  value="<?= $a['flow-eip-2-2']; ?>" class="form-control" placeholder="flow-eip-2-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3-2" id="flow-name-3-2-<?= $i; ?>"  value="<?= $a['flow-name-3-2']; ?>" class="form-control" placeholder="flow-name-3-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3-2" id="flow-value-3-2-<?= $i; ?>"  value="<?= $a['flow-value-3-2']; ?>" class="form-control" placeholder="flow-value-3-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3-2" id="flow-unit-3-2-<?= $i; ?>"  value="<?= $a['flow-unit-3-2']; ?>" class="form-control" placeholder="flow-unit-3-2"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3-2" id="flow-opex-3-2-<?= $i; ?>"  value="<?= $a['flow-opex-3-2']; ?>" class="form-control" placeholder="flow-opex-3-2" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1-2" id="ecoben-eip-1-2-<?= $i; ?>"  value="<?= $a['ecoben-eip-1-2']; ?>" class="form-control" placeholder="ecoben-eip-1-2" ></div>
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1-3" id="flow-name-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1-3']; ?>" placeholder="Fill or ...">
                <select name="flow_name" id="select-flow-1-3-<?= $i; ?>" onchange="insertFlowRow(this)" class="dropdown" style="overflow:visible; position:relative;">
                    <option value="">select flow</option>
                    <?php foreach ($allocated_flows as $flowname): ?>
                        <option value="<?= $flowname['allocation_id']; ?>"><?= $flowname['prcss_name'] .": ". $flowname['flow_name']; ?> (<?= $flowname['flow_type_name']; ?>)</option>
                    <?php endforeach ?>
                </select>
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1-3" id="flow-value-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1-3']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1-3" id="flow-unit-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-unit-1-3']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1-3" id="flow-specost-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1-3']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1-3" id="flow-opex-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1-3']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1-3" id="flow-eipunit-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1-3']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1-3" id="flow-eip-1-3-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eip-1-3']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2-3" id="flow-name-2-3-<?= $i; ?>"  value="<?= $a['flow-name-2-3']; ?>" class="form-control" placeholder="flow-name-2-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2-3" id="flow-value-2-3-<?= $i; ?>"  value="<?= $a['flow-value-2-3']; ?>" class="form-control" placeholder="flow-value-2-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2-3" id="flow-unit-2-3-<?= $i; ?>"  value="<?= $a['flow-unit-2-3']; ?>" class="form-control" placeholder="flow-unit-2-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2-3" id="flow-specost-2-3-<?= $i; ?>"  value="<?= $a['flow-specost-2-3']; ?>" class="form-control" placeholder="flow-specost-2-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2-3" id="flow-opex-2-3-<?= $i; ?>"  value="<?= $a['flow-opex-2-3']; ?>" class="form-control" placeholder="flow-opex-2-3" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2-3" id="flow-eipunit-2-3-<?= $i; ?>"  value="<?= $a['flow-eipunit-2-3']; ?>" class="form-control" placeholder="flow-eipunit-2-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2-3" id="flow-eip-2-3-<?= $i; ?>"  value="<?= $a['flow-eip-2-3']; ?>" class="form-control" placeholder="flow-eip-2-3" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3-3" id="flow-name-3-3-<?= $i; ?>"  value="<?= $a['flow-name-3-3']; ?>" class="form-control" placeholder="flow-name-3-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3-3" id="flow-value-3-3-<?= $i; ?>"  value="<?= $a['flow-value-3-3']; ?>" class="form-control" placeholder="flow-value-3-3" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3-3" id="flow-unit-3-3-<?= $i; ?>"  value="<?= $a['flow-unit-3-3']; ?>" class="form-control" placeholder="flow-unit-3-3"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3-3" id="flow-opex-3-3-<?= $i; ?>"  value="<?= $a['flow-opex-3-3']; ?>" class="form-control" placeholder="flow-opex-3-3" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1-3" id="ecoben-eip-1-3-<?= $i; ?>"  value="<?= $a['ecoben-eip-1-3']; ?>" class="form-control" placeholder="ecoben-eip-1-3" ></div>
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1-4" id="flow-name-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1-4']; ?>" placeholder="Fill or ...">
                <select name="flow_name" id="select-flow-1-4-<?= $i; ?>" onchange="insertFlowRow(this)" class="dropdown" style="overflow:visible; position:relative;">
                    <option value="">select flow</option>
                    <?php foreach ($allocated_flows as $flowname): ?>
                        <option value="<?= $flowname['allocation_id']; ?>"><?= $flowname['prcss_name'] .": ". $flowname['flow_name']; ?> (<?= $flowname['flow_type_name']; ?>)</option>
                    <?php endforeach ?>
                </select>
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1-4" id="flow-value-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1-4']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1-4" id="flow-unit-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-unit-1-4']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1-4" id="flow-specost-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1-4']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1-4" id="flow-opex-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1-4']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1-4" id="flow-eipunit-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1-4']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1-4" id="flow-eip-1-4-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eip-1-4']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2-4" id="flow-name-2-4-<?= $i; ?>"  value="<?= $a['flow-name-2-4']; ?>" class="form-control" placeholder="flow-name-2-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2-4" id="flow-value-2-4-<?= $i; ?>"  value="<?= $a['flow-value-2-4']; ?>" class="form-control" placeholder="flow-value-2-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2-4" id="flow-unit-2-4-<?= $i; ?>"  value="<?= $a['flow-unit-2-4']; ?>" class="form-control" placeholder="flow-unit-2-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2-4" id="flow-specost-2-4-<?= $i; ?>"  value="<?= $a['flow-specost-2-4']; ?>" class="form-control" placeholder="flow-specost-2-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2-4" id="flow-opex-2-4-<?= $i; ?>"  value="<?= $a['flow-opex-2-4']; ?>" class="form-control" placeholder="flow-opex-2-4" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2-4" id="flow-eipunit-2-4-<?= $i; ?>"  value="<?= $a['flow-eipunit-2-4']; ?>" class="form-control" placeholder="flow-eipunit-2-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2-4" id="flow-eip-2-4-<?= $i; ?>"  value="<?= $a['flow-eip-2-4']; ?>" class="form-control" placeholder="flow-eip-2-4" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3-4" id="flow-name-3-4-<?= $i; ?>"  value="<?= $a['flow-name-3-4']; ?>" class="form-control" placeholder="flow-name-3-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3-4" id="flow-value-3-4-<?= $i; ?>"  value="<?= $a['flow-value-3-4']; ?>" class="form-control" placeholder="flow-value-3-4" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3-4" id="flow-unit-3-4-<?= $i; ?>"  value="<?= $a['flow-unit-3-4']; ?>" class="form-control" placeholder="flow-unit-3-4"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3-4" id="flow-opex-3-4-<?= $i; ?>"  value="<?= $a['flow-opex-3-4']; ?>" class="form-control" placeholder="flow-opex-3-4" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1-4" id="ecoben-eip-1-4-<?= $i; ?>"  value="<?= $a['ecoben-eip-1-4']; ?>" class="form-control" placeholder="ecoben-eip-1-4" ></div>
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1-5" id="flow-name-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1-5']; ?>" placeholder="Fill or ...">
                <select name="flow_name" id="select-flow-1-5-<?= $i; ?>" onchange="insertFlowRow(this)" class="dropdown" style="overflow:visible; position:relative;">
                    <option value="">select flow</option>
                    <?php foreach ($allocated_flows as $flowname): ?>
                        <option value="<?= $flowname['allocation_id']; ?>"><?= $flowname['prcss_name'] .": ". $flowname['flow_name']; ?> (<?= $flowname['flow_type_name']; ?>)</option>
                    <?php endforeach ?>
                </select>
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1-5" id="flow-value-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1-5']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1-5" id="flow-unit-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-unit-1-5']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1-5" id="flow-specost-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1-5']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1-5" id="flow-opex-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1-5']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1-5" id="flow-eipunit-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1-5']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1-5" id="flow-eip-1-5-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eip-1-5']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2-5" id="flow-name-2-5-<?= $i; ?>"  value="<?= $a['flow-name-2-5']; ?>" class="form-control" placeholder="flow-name-2-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2-5" id="flow-value-2-5-<?= $i; ?>"  value="<?= $a['flow-value-2-5']; ?>" class="form-control" placeholder="flow-value-2-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2-5" id="flow-unit-2-5-<?= $i; ?>"  value="<?= $a['flow-unit-2-5']; ?>" class="form-control" placeholder="flow-unit-2-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2-5" id="flow-specost-2-5-<?= $i; ?>"  value="<?= $a['flow-specost-2-5']; ?>" class="form-control" placeholder="flow-specost-2-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2-5" id="flow-opex-2-5-<?= $i; ?>"  value="<?= $a['flow-opex-2-5']; ?>" class="form-control" placeholder="flow-opex-2-5" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2-5" id="flow-eipunit-2-5-<?= $i; ?>"  value="<?= $a['flow-eipunit-2-5']; ?>" class="form-control" placeholder="flow-eipunit-2-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2-5" id="flow-eip-2-5-<?= $i; ?>"  value="<?= $a['flow-eip-2-5']; ?>" class="form-control" placeholder="flow-eip-2-5" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3-5" id="flow-name-3-5-<?= $i; ?>"  value="<?= $a['flow-name-3-5']; ?>" class="form-control" placeholder="flow-name-3-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3-5" id="flow-value-3-5-<?= $i; ?>"  value="<?= $a['flow-value-3-5']; ?>" class="form-control" placeholder="flow-value-3-5" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3-5" id="flow-unit-3-5-<?= $i; ?>"  value="<?= $a['flow-unit-3-5']; ?>" class="form-control" placeholder="flow-unit-3-5"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3-5" id="flow-opex-3-5-<?= $i; ?>"  value="<?= $a['flow-opex-3-5']; ?>" class="form-control" placeholder="flow-opex-3-5" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1-5" id="ecoben-eip-1-5-<?= $i; ?>"  value="<?= $a['ecoben-eip-1-5']; ?>" class="form-control" placeholder="ecoben-eip-1-5" ></div>
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-1-6" id="flow-name-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-name-1-6']; ?>" placeholder="Fill or ...">
                <select name="flow_name" id="select-flow-1-6-<?= $i; ?>" onchange="insertFlowRow(this)" class="dropdown" style="overflow:visible; position:relative;">
                    <option value="">select flow</option>
                    <?php foreach ($allocated_flows as $flowname): ?>
                        <option value="<?= $flowname['allocation_id']; ?>"><?= $flowname['prcss_name'] .": ". $flowname['flow_name']; ?> (<?= $flowname['flow_type_name']; ?>)</option>
                    <?php endforeach ?>
                </select>
            </div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-1-6" id="flow-value-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-value-1-6']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-1-6" id="flow-unit-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-unit-1-6']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-1-6" id="flow-specost-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-specost-1-6']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-1-6" id="flow-opex-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-opex-1-6']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-1-6" id="flow-eipunit-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eipunit-1-6']; ?>" placeholder="Fill"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-1-6" id="flow-eip-1-6-<?= $i; ?>" class="form-control  " value="<?= $a['flow-eip-1-6']; ?>" placeholder="Fill" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-2-6" id="flow-name-2-6-<?= $i; ?>"  value="<?= $a['flow-name-2-6']; ?>" class="form-control" placeholder="flow-name-2-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-2-6" id="flow-value-2-6-<?= $i; ?>"  value="<?= $a['flow-value-2-6']; ?>" class="form-control" placeholder="flow-value-2-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-2-6" id="flow-unit-2-6-<?= $i; ?>"  value="<?= $a['flow-unit-2-6']; ?>" class="form-control" placeholder="flow-unit-2-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-specost-2-6" id="flow-specost-2-6-<?= $i; ?>"  value="<?= $a['flow-specost-2-6']; ?>" class="form-control" placeholder="flow-specost-2-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-2-6" id="flow-opex-2-6-<?= $i; ?>"  value="<?= $a['flow-opex-2-6']; ?>" class="form-control" placeholder="flow-opex-2-6" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eipunit-2-6" id="flow-eipunit-2-6-<?= $i; ?>"  value="<?= $a['flow-eipunit-2-6']; ?>" class="form-control" placeholder="flow-eipunit-2-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-eip-2-6" id="flow-eip-2-6-<?= $i; ?>"  value="<?= $a['flow-eip-2-6']; ?>" class="form-control" placeholder="flow-eip-2-6" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-name-3-6" id="flow-name-3-6-<?= $i; ?>"  value="<?= $a['flow-name-3-6']; ?>" class="form-control" placeholder="flow-name-3-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-value-3-6" id="flow-value-3-6-<?= $i; ?>"  value="<?= $a['flow-value-3-6']; ?>" class="form-control" placeholder="flow-value-3-6" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-unit-3-6" id="flow-unit-3-6-<?= $i; ?>"  value="<?= $a['flow-unit-3-6']; ?>" class="form-control" placeholder="flow-unit-3-6"></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="flow-opex-3-6" id="flow-opex-3-6-<?= $i; ?>"  value="<?= $a['flow-opex-3-6']; ?>" class="form-control" placeholder="flow-opex-3-6" ></div>
        </td>
        <td class="tg-yw4l">
            <div class="  "><input type="text" name="ecoben-eip-1-6" id="ecoben-eip-1-6-<?= $i; ?>"  value="<?= $a['ecoben-eip-1-6']; ?>" class="form-control" placeholder="ecoben-eip-1-6" ></div>
        </td>
    </tr>
    <tr>
        <td class="tg-yw4l"></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">Maintenance</td>
        <td class="tg-yw4l"><div class="  "><input type="text" name="maintan-1" id="maintan-1-<?= $i; ?>"  value="<?= set_value('maintan-1', '0'); ?>" class="form-control" placeholder="maintan-1"></div></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">SUM</td>
        <td class="tg-yw4l"><div class="  "><input type="text" name="sum-1" id="sum-1-<?= $i; ?>"  value="<?= $a['sum-1']; ?>" class="form-control" placeholder="sum-1" ></div></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">SUM</td>
        <td class="tg-yw4l"><div class="  "><input type="text" name="sum-2" id="sum-2-<?= $i; ?>"  value="<?= $a['sum-2']; ?>" class="form-control" placeholder="sum-2" ></div></td>
        <td class="tg-yw4l"></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">Maintenance</td>
        <td class="tg-yw4l"><div class="  "><input type="text" name="maintan-1-2" id="maintan-1-2-<?= $i; ?>"  value="<?= set_value('maintan-1-2', '0'); ?>" class="form-control" placeholder="maintan-1-2"></div></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">SUM</td>
        <td class="tg-yw4l"><div class=""><input type="text" name="sum-1-1" id="sum-1-1-<?= $i; ?>"  value="<?= $a['sum-1-1']; ?>" class="form-control" placeholder="sum-1-1" ></div></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">SUM</td>
        <td class="tg-yw4l"><div class=""><input type="text" name="sum-2-1" id="sum-2-1-<?= $i; ?>"  value="<?= $a['sum-2-1']; ?>" class="form-control" placeholder="sum-2-1" ></div></td>
        <td class="tg-yw4l"></td>
        <td class="tg-yw4l"></td>
        <td class="tg-yw4l" style="font-weight:bold; color:black;">SUM</td>
        <td class="tg-yw4l"><div class=""><input type="text" name="sum-3-1" id="sum-3-1-<?= $i; ?>"  value="<?= $a['sum-3-1']; ?>" class="form-control" placeholder="sum-3-1" ></div></td>
        <td class="tg-yw4l"><div class=""><input type="text" name="sum-3-2" id="sum-3-2-<?= $i; ?>"  
            value="<?= number_format((float)$a['sum-3-2'], 2, '.', "'"); ?>" class="form-control" placeholder="sum-3-2" ></div></td>
    </tr>
</table>
</br>

    <?php $i++; ?>
	</form>
	<script type="text/javascript">
    	//$( document ).ready(calculate);
    </script>
    <?php endforeach ?>
<?php else: ?>
    No Cost - Benefit option active, check the  <a href="<?= base_url('cpscoping'); ?>">allocations and KPI calculation page </a> (comment is mandatory and "Is option" needs to be set)
<?php endif; ?>
<hr>
</div>

<!-- bottom part of the page with summary table starts here-->
<div class="col-md-6">
    <p><?= lang("cbaheading2"); ?></p>
        <?php if (!empty($allocation)): ?>
            <?php if(empty($allocation[0]['unit_cost'])){$allocation[0]['unit_cost']="-";} ?>
            <table class="table" style="font-size:12px;">
                <tr>
                    <th><?= lang("optionandprocess"); ?></th>
                   <th style="text-align: right;"><?= lang("marginalcost"); ?> (<?= $allocation[0]['unit_cost']; ?>/EP)</th>
                    <th style="text-align: right;"><?= lang("ecologicalbenefit"); ?> (EP)</th>
                </tr>
            <?php foreach ($allocation as $a): ?>
                <tr>
                    <td>
                    <?php 
                    if(empty($a['cmpny_from_name'])) {
                        echo "<div style='font-size:13px;'>".$a['best']."</div>";
                        echo "<small style='font-size:11px; color:#999; '>".$a['prcss_name']." - ".$a['flow_name']." - ".$a['flow_type_name']."</small>";

                    }
                    else {
                        echo $a['flow_name']." input IS potential from/to ".$a['cmpny_from_name']; 
                    } ?>
                    </td>
                    <td style="text-align: right;"><?= number_format((float)$a['marcos-1'], 2, '.', "'"); ?></td>
                    <td style="text-align: right;"><?= number_format((float)$a['sum-3-2'], 2, '.', "'"); ?></td></tr>
            <?php endforeach ?>
            </table>
        <?php endif ?>
	<?php if (!empty($allocation)): ?>
        <?php //print_r($allocation); ?>
			<?php $i=1; ?>
			<?php foreach ($allocation as $a): ?>
				<?php if(!empty($a['cp_id'])){$iid=$a['cp_id']; $tip="cp";}else{$iid=$a['is_id'];$tip="is";} ?>
 				<?php $attributes = array('id' => 'form-'.$i); ?>
				<?php // echo form_open('cba/save/'.$this->uri->segment(2).'/'.$this->uri->segment(3).'/'.$iid.'/'.$tip, $attributes); ?>
				<!-- <table class="costtable">
					<tr>
						<td>#</td><td><?= $i; ?></td>
					</tr>
					<tr>
						<td width="250"><?= lang("option"); ?></td>
						<td width="75%">
						<?php //print_r($a); ?>
							<b><?php if(!empty($a['prcss_name'])) {echo $a['prcss_name'];} else {echo "IS potential"; } ?></b> 
							<small class="text-muted"><?= $a['flow_name']; ?><?php if(!empty($a['prcss_name'])) {echo "-".$a['flow_type_name']; } ?></small><br>
							<span class="text-info">
								<?php if(empty($a['cmpny_from_name'])) {echo $a['best'];} else {echo $a['flow_name']." input IS potential from ".$a['cmpny_from_name']; } ?>
							</span>
						</td>
					</tr>
					<tr>
						<td><?= lang("discountrate"); ?> (%)</td>
						<td><div class="  "><input type="text" name="disrate" id="disrate-<?= $i; ?>"  value="<?= $a['disrate']; ?>" class="form-control" placeholder="You should fill this field."></div></td>
					</tr>
						<tr><td><?= lang("capexold"); ?> (<?= $a['unit_cost']; ?>/<?= lang("year"); ?>)</td>								
						<td><div class="  "><input type="text" name="capexold" id="capexold-<?= $i; ?>" class="form-control  " value="<?= $a['capexold']; ?>" placeholder="You should fill this field."></div></td>
					</tr>
					<tr>
						<td><?= lang("opexold"); ?> (<?= $a['unit_cost']; ?>/<?= lang("year"); ?>)</td>
						<td><input type="text" name="opexold" id="opexold-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("lifetimeold"); ?> (<?= lang("year"); ?>)</td>
						<td><div class="  "><input type="text" name="ltold" id="ltold-<?= $i; ?>" value="<?= $a['ltold']; ?>" class="form-control" placeholder="You should fill this field."></div></td>
					</tr>
					<tr>
						<td><?= lang("capexnew"); ?> (<?= $a['unit_cost']; ?>/<?= lang("year"); ?>)</td>
						<td><div class="  "><input type="text" name="capexnew" id="capexnew-<?= $i; ?>" value="<?= $a['capexnew']; ?>" class="form-control" placeholder="You should fill this field."></div></td>
					</tr>
					<tr>
						<td><?= lang("opexnew"); ?> (<?= $a['unit_cost']; ?>/<?= lang("year"); ?>)</td>
						<td><input type="text" name="opexnew" id="opexnew-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("lifetimenew"); ?> (<?= lang("year"); ?>)</td>
						<td><div class="  "><input type="text" name="ltnew" id="ltnew-<?= $i; ?>" value="<?= $a['ltnew']; ?>" class="form-control" placeholder="You should fill this field."></div></td>
					</tr>
					<tr>
						<td><?= lang("anncostold"); ?></td>
						<td><input type="text" name="acold" id="acold-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("anncostnew"); ?></td>
						<td><input type="text" name="acnew" id="acnew-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("economiccostbenefit"); ?></td>
						<td><input type="text" name="eco" id="eco-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("unit"); ?></td>
						<td>Euro/<?= lang("year"); ?></td>
					</tr>
					<tr>
						<td><?= lang("oldcons"); ?></td><td><input type="text" name="oldcons" id="oldcons-<?= $i; ?>" class="form-control" value="<?= $a['qntty']; ?>"></td>
					</tr>
					<tr>
						<td><?= lang("oldcost"); ?></td><td><input type="text" name="oldcost" id="oldcost-<?= $i; ?>" class="form-control" value="<?= $a['cost']; ?>"></td>
					</tr>
					<tr>
						<td><?= lang("oldep"); ?></td><td><input type="text" name="oldep" id="oldep-<?= $i; ?>" class="form-control" value="<?= $a['ep']; ?>"></td>
					</tr>
					<tr>
						<td><?= lang("newcons"); ?></td>
						<td><div class="  "><input type="text" name="newcons" id="newcons-<?= $i; ?>" value="<?= $a['newcons']; ?>" class="form-control" placeholder="You should fill this field."></div></td>
					</tr>
					<tr>
						<td><?= lang("unit"); ?></td>
						<td><input type="hidden" name="unit2" value="<?= $a['qntty_unit']; ?>/<?= lang('year'); ?>" > <?= $a['qntty_unit']; ?>/<?= lang("year"); ?></td>
					</tr>
					<tr>
						<td><?= $a['unit_cost']; ?>/ <?= lang("unit"); ?></td>
						<td><input type="text" name="euunit" id="euunit-<?= $i; ?>" class="form-control" value="<?= ($a['cost']/$a['qntty']); ?>" ></td>
					</tr>
					<tr>
						<td>EP/ <?= lang("unit"); ?></td>
						<td><input type="text" name="eipunit" id="eipunit-<?= $i; ?>" class="form-control" value="<?= ($a['ep']/$a['qntty']); ?>" ></td>
					</tr>
					<tr>
						<td><?= lang("ecologicalbenefit"); ?></td>
						<td><input type="text" name="ecoben" id="ecoben-<?= $i; ?>" class="form-control"></td>
					</tr>
					<tr>
						<td><?= lang("unit"); ?></td>
						<td>EP/<?= lang("year"); ?></td>
					</tr>
					<tr>
						<td><?= lang("marginalcost"); ?></td>
						<td><input type="text" name="marcos" id="marcos-<?= $i; ?>" class="form-control"></td>	
					</tr>
					<tr>
						<td><?= lang("unit"); ?></td><td>$/EP</td>
					</tr>
				</table>
				<input type="submit" value="<?= lang("save"); ?>" class="btn btn-block btn-info" style="margin-top:20px;"/> -->
				<script type="text/javascript">
                    
				/*	$('#form-<?= $i; ?> input').keydown(function(e){
						
						// Allow: backspace, delete, tab, escape, enter and .
						if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
						     // Allow: Ctrl+A
						    (e.keyCode == 65 && e.ctrlKey === true) || 
						     // Allow: home, end, left, right, down, up
						    (e.keyCode >= 35 && e.keyCode <= 40)) {
						         // let it happen, don't do anything
						         return;
						}
						// Ensure that it is a number and stop the keypress
						if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
						    e.preventDefault();
						}

						//console.log("x<?= $i; ?>");
					});*/

					function calculate(){

                        //OPEX old-1
                        $("#flow-opex-1-<?= $i; ?>").attr('value',($("#flow-specost-1-<?= $i; ?>").val()*$("#flow-value-1-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2
                        $("#flow-opex-1-2-<?= $i; ?>").val(($("#flow-specost-1-2-<?= $i; ?>").val()*$("#flow-value-1-2-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-3
                        $("#flow-opex-1-3-<?= $i; ?>").val(($("#flow-specost-1-3-<?= $i; ?>").val()*$("#flow-value-1-3-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-4
                        $("#flow-opex-1-4-<?= $i; ?>").val(($("#flow-specost-1-4-<?= $i; ?>").val()*$("#flow-value-1-4-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-5
                        $("#flow-opex-1-5-<?= $i; ?>").val(($("#flow-specost-1-5-<?= $i; ?>").val()*$("#flow-value-1-5-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-6
                        $("#flow-opex-1-6-<?= $i; ?>").val(($("#flow-specost-1-6-<?= $i; ?>").val()*$("#flow-value-1-6-<?= $i; ?>").val()).toFixed(2));

                        //sum-1
                        $("#sum-1-<?= $i; ?>").val((parseFloat($("#flow-opex-1-<?= $i; ?>").val())+parseFloat($("#flow-opex-1-2-<?= $i; ?>").val())+parseFloat($("#flow-opex-1-3-<?= $i; ?>").val())+parseFloat($("#flow-opex-1-4-<?= $i; ?>").val())+parseFloat($("#flow-opex-1-5-<?= $i; ?>").val())+parseFloat($("#flow-opex-1-6-<?= $i; ?>").val())+parseFloat($("#maintan-1-<?= $i; ?>").val())).toFixed(2));

                        //flow eip-1
                        $("#flow-eip-1-<?= $i; ?>").val(($("#flow-eipunit-1-<?= $i; ?>").val()*$("#flow-value-1-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2
                        $("#flow-eip-1-2-<?= $i; ?>").val(($("#flow-eipunit-1-2-<?= $i; ?>").val()*$("#flow-value-1-2-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-3
                        $("#flow-eip-1-3-<?= $i; ?>").val(($("#flow-eipunit-1-3-<?= $i; ?>").val()*$("#flow-value-1-3-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-4
                        $("#flow-eip-1-4-<?= $i; ?>").val(($("#flow-eipunit-1-4-<?= $i; ?>").val()*$("#flow-value-1-4-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-5
                        $("#flow-eip-1-5-<?= $i; ?>").val(($("#flow-eipunit-1-5-<?= $i; ?>").val()*$("#flow-value-1-5-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-6
                        $("#flow-eip-1-6-<?= $i; ?>").val(($("#flow-eipunit-1-6-<?= $i; ?>").val()*$("#flow-value-1-6-<?= $i; ?>").val()).toFixed(4));

                        //sum-2
                        $("#sum-2-<?= $i; ?>").val((parseFloat($("#flow-eip-1-<?= $i; ?>").val())+parseFloat($("#flow-eip-1-2-<?= $i; ?>").val())+parseFloat($("#flow-eip-1-3-<?= $i; ?>").val())+parseFloat($("#flow-eip-1-4-<?= $i; ?>").val())+parseFloat($("#flow-eip-1-5-<?= $i; ?>").val())+parseFloat($("#flow-eip-1-6-<?= $i; ?>").val())).toFixed(4));

                        //annual-cost-1
                        $("#annual-cost-1-<?= $i; ?>").val((parseFloat($("#sum-1-<?= $i; ?>").val())+parseFloat($("#capexold-<?= $i; ?>").val())).toFixed(2));

                        //Ann. costs old option calculation
                        //D3*(J3*(1+J3)^F3)/((1+J3)^F3-1)+E3
                        //capexold*(Discount*(1+Discount)^Lifetimeold)/(((1+Discount)^Lifetimeold)-1)+opexold
                        $("#capex-1-<?= $i; ?>").val((
                            parseFloat($("#investment-<?= $i; ?>").val()*( 
                                $("#disrate-<?= $i; ?>").val()/100 * 
                                    Math.pow(
                                        ((1)+parseFloat($("#disrate-<?= $i; ?>").val()/100)),$("#ltold-<?= $i; ?>").val()
                                    ))/(parseFloat(
                                    Math.pow(
                                        ((1)+parseFloat($("#disrate-<?= $i; ?>").val()/100)),$("#ltold-<?= $i; ?>").val()
                                    )
                                )-(1))).toFixed(2))
                        );

                        if(isNaN($("#capex-1-<?= $i; ?>").val())){$("#capex-1-<?= $i; ?>").val("0");}

                        //OPEX old-2-1
                        $("#flow-opex-2-<?= $i; ?>").val(($("#flow-specost-2-<?= $i; ?>").val()*$("#flow-value-2-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2-2
                        $("#flow-opex-2-2-<?= $i; ?>").val(($("#flow-specost-2-2-<?= $i; ?>").val()*$("#flow-value-2-2-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2-3
                        $("#flow-opex-2-3-<?= $i; ?>").val(($("#flow-specost-2-3-<?= $i; ?>").val()*$("#flow-value-2-3-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2-4
                        $("#flow-opex-2-4-<?= $i; ?>").val(($("#flow-specost-2-4-<?= $i; ?>").val()*$("#flow-value-2-4-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2-5
                        $("#flow-opex-2-5-<?= $i; ?>").val(($("#flow-specost-2-5-<?= $i; ?>").val()*$("#flow-value-2-5-<?= $i; ?>").val()).toFixed(2));

                        //OPEX old-2-6
                        $("#flow-opex-2-6-<?= $i; ?>").val(($("#flow-specost-2-6-<?= $i; ?>").val()*$("#flow-value-2-6-<?= $i; ?>").val()).toFixed(2));

                        //flow eip-2
                        $("#flow-eip-2-<?= $i; ?>").val(($("#flow-eipunit-2-<?= $i; ?>").val()*$("#flow-value-2-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2-2
                        $("#flow-eip-2-2-<?= $i; ?>").val(($("#flow-eipunit-2-2-<?= $i; ?>").val()*$("#flow-value-2-2-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2-3
                        $("#flow-eip-2-3-<?= $i; ?>").val(($("#flow-eipunit-2-3-<?= $i; ?>").val()*$("#flow-value-2-3-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2-4
                        $("#flow-eip-2-4-<?= $i; ?>").val(($("#flow-eipunit-2-4-<?= $i; ?>").val()*$("#flow-value-2-4-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2-5
                        $("#flow-eip-2-5-<?= $i; ?>").val(($("#flow-eipunit-2-5-<?= $i; ?>").val()*$("#flow-value-2-5-<?= $i; ?>").val()).toFixed(4));
                        //flow eip-2-6
                        $("#flow-eip-2-6-<?= $i; ?>").val(($("#flow-eipunit-2-6-<?= $i; ?>").val()*$("#flow-value-2-6-<?= $i; ?>").val()).toFixed(4));

                         //sum-2
                        $("#sum-1-1-<?= $i; ?>").val((parseFloat($("#flow-opex-2-<?= $i; ?>").val())+parseFloat($("#flow-opex-2-2-<?= $i; ?>").val())+parseFloat($("#flow-opex-2-3-<?= $i; ?>").val())+parseFloat($("#flow-opex-2-4-<?= $i; ?>").val())+parseFloat($("#flow-opex-2-5-<?= $i; ?>").val())+parseFloat($("#flow-opex-2-6-<?= $i; ?>").val())+parseFloat($("#maintan-1-2-<?= $i; ?>").val())).toFixed(2));

                         //eip2-1
                        $("#sum-2-1-<?= $i; ?>").val((parseFloat($("#flow-eip-2-<?= $i; ?>").val())+parseFloat($("#flow-eip-2-2-<?= $i; ?>").val())+parseFloat($("#flow-eip-2-3-<?= $i; ?>").val())+parseFloat($("#flow-eip-2-4-<?= $i; ?>").val())+parseFloat($("#flow-eip-2-5-<?= $i; ?>").val())+parseFloat($("#flow-eip-2-6-<?= $i; ?>").val())).toFixed(4));

                        //annual-cost-2
                        $("#annual-cost-2-<?= $i; ?>").val(parseFloat($("#sum-1-1-<?= $i; ?>").val())+parseFloat($("#capex-1-<?= $i; ?>").val()));

                        //difference-1
                        $("#flow-value-3-<?= $i; ?>").val(parseFloat($("#flow-value-1-<?= $i; ?>").val())-parseFloat($("#flow-value-2-<?= $i; ?>").val()));
                        //difference-2
                        $("#flow-value-3-2-<?= $i; ?>").val(parseFloat($("#flow-value-1-2-<?= $i; ?>").val())-parseFloat($("#flow-value-2-2-<?= $i; ?>").val()));
                        //difference-3
                        $("#flow-value-3-3-<?= $i; ?>").val(parseFloat($("#flow-value-1-3-<?= $i; ?>").val())-parseFloat($("#flow-value-2-3-<?= $i; ?>").val()));                        
                        //difference-4
                        $("#flow-value-3-4-<?= $i; ?>").val(parseFloat($("#flow-value-1-4-<?= $i; ?>").val())-parseFloat($("#flow-value-2-4-<?= $i; ?>").val()));                        
                        //difference-5
                        $("#flow-value-3-5-<?= $i; ?>").val(parseFloat($("#flow-value-1-5-<?= $i; ?>").val())-parseFloat($("#flow-value-2-5-<?= $i; ?>").val()));                        
                        //difference-6
                        $("#flow-value-3-6-<?= $i; ?>").val(parseFloat($("#flow-value-1-6-<?= $i; ?>").val())-parseFloat($("#flow-value-2-6-<?= $i; ?>").val()));


                        //opex_dif-1
                        $("#flow-opex-3-<?= $i; ?>").val(parseFloat($("#flow-opex-1-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-<?= $i; ?>").val()));
                        //opex_dif-2
                        $("#flow-opex-3-2-<?= $i; ?>").val(parseFloat($("#flow-opex-1-2-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-2-<?= $i; ?>").val()));
                        //opex_dif-3
                        $("#flow-opex-3-3-<?= $i; ?>").val(parseFloat($("#flow-opex-1-3-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-3-<?= $i; ?>").val()));                        
                        //opex_dif-4
                        $("#flow-opex-3-4-<?= $i; ?>").val(parseFloat($("#flow-opex-1-4-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-4-<?= $i; ?>").val()));                        
                        //opex_dif-5
                        $("#flow-opex-3-5-<?= $i; ?>").val(parseFloat($("#flow-opex-1-5-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-5-<?= $i; ?>").val()));                        
                        //opex_dif-6
                        $("#flow-opex-3-6-<?= $i; ?>").val(parseFloat($("#flow-opex-1-6-<?= $i; ?>").val())-parseFloat($("#flow-opex-2-6-<?= $i; ?>").val()));

                        //opex_dif-1
                        $("#ecoben-eip-1-<?= $i; ?>").val(parseFloat($("#flow-eip-1-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-<?= $i; ?>").val()));
                        //opex_dif-2
                        $("#ecoben-eip-1-2-<?= $i; ?>").val(parseFloat($("#flow-eip-1-2-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-2-<?= $i; ?>").val()));
                        //opex_dif-3
                        $("#ecoben-eip-1-3-<?= $i; ?>").val(parseFloat($("#flow-eip-1-3-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-3-<?= $i; ?>").val()));                        
                        //opex_dif-4
                        $("#ecoben-eip-1-4-<?= $i; ?>").val(parseFloat($("#flow-eip-1-4-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-4-<?= $i; ?>").val()));                        
                        //opex_dif-5
                        $("#ecoben-eip-1-5-<?= $i; ?>").val(parseFloat($("#flow-eip-1-5-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-5-<?= $i; ?>").val()));                        
                        //opex_dif-6
                        $("#ecoben-eip-1-6-<?= $i; ?>").val(parseFloat($("#flow-eip-1-6-<?= $i; ?>").val())-parseFloat($("#flow-eip-2-6-<?= $i; ?>").val()));

                        //sum-3-1
                        $("#sum-3-1-<?= $i; ?>").val((parseFloat($("#flow-opex-3-<?= $i; ?>").val())+parseFloat($("#flow-opex-3-2-<?= $i; ?>").val())+parseFloat($("#flow-opex-3-3-<?= $i; ?>").val())+parseFloat($("#flow-opex-3-4-<?= $i; ?>").val())+parseFloat($("#flow-opex-3-5-<?= $i; ?>").val())+parseFloat($("#flow-opex-3-6-<?= $i; ?>").val())).toFixed(2));

                        //sum-3-2
                        $("#sum-3-2-<?= $i; ?>").val((parseFloat($("#ecoben-eip-1-<?= $i; ?>").val())+parseFloat($("#ecoben-eip-1-2-<?= $i; ?>").val())+parseFloat($("#ecoben-eip-1-3-<?= $i; ?>").val())+parseFloat($("#ecoben-eip-1-4-<?= $i; ?>").val())+parseFloat($("#ecoben-eip-1-5-<?= $i; ?>").val())+parseFloat($("#ecoben-eip-1-6-<?= $i; ?>").val())).toFixed(4));

                        //ecoben-1
                        $("#ecoben-1-<?= $i; ?>").val(parseFloat($("#annual-cost-2-<?= $i; ?>").val())-parseFloat($("#annual-cost-1-<?= $i; ?>").val()));

                        //marcos-1
                        $("#marcos-1-<?= $i; ?>").val((parseFloat($("#ecoben-1-<?= $i; ?>").val())/parseFloat($("#sum-3-2-<?= $i; ?>").val())).toFixed(2));

                        //payback-1
                        $("#payback-1-<?= $i; ?>").val(((parseFloat($("#ltold-<?= $i; ?>").val())*parseFloat($("#capex-1-<?= $i; ?>").val()))/(parseFloat($("#sum-1-<?= $i; ?>").val())-parseFloat($("#sum-1-1-<?= $i; ?>").val()))).toFixed(2));
                        //------------------------------

						//OPEX OLD calculation
						$("#opexold-<?= $i; ?>").val($("#oldcons-<?= $i; ?>").val()*$("#euunit-<?= $i; ?>").val());

						//OPEX NEW calculation
						$("#opexnew-<?= $i; ?>").val($("#newcons-<?= $i; ?>").val()*$("#euunit-<?= $i; ?>").val());

						/*
						console.log(
							Math.pow(
										((1)+parseFloat($("#disrate-<?= $i; ?>").val()/100)),$("#ltold-<?= $i; ?>").val()
								)-(1)
						);
						console.log(parseFloat($("#disrate-<?= $i; ?>").val()/100));
						console.log(parseFloat($("#ltold-<?= $i; ?>").val()));
						*/

						//Ann. costs new option calculation
						//D3*(J3*(1+J3)^F3)/((1+J3)^F3-1)+E3
						//capexold*(Discount*(1+Discount)^Lifetimeold)/(((1+Discount)^Lifetimeold)-1)+opexold
						/*$("#acnew-<?= $i; ?>").val( 
							parseFloat($("#capexnew-<?= $i; ?>").val()*( 
								$("#disrate-<?= $i; ?>").val()/100 * 
									Math.pow(
										((1)+parseFloat($("#disrate-<?= $i; ?>").val()/100)),$("#ltnew-<?= $i; ?>").val()
									))/(parseFloat(
									Math.pow(
										((1)+parseFloat($("#disrate-<?= $i; ?>").val()/100)),$("#ltnew-<?= $i; ?>").val()
									)
								)-(1)))
							+ parseFloat($("#opexnew-<?= $i; ?>").val())
						);

						//Ecological Benefit calculation
						$("#ecoben-<?= $i; ?>").val(-$("#eipunit-<?= $i; ?>").val() * ($("#newcons-<?= $i; ?>").val()-$("#oldcons-<?= $i; ?>").val()));
						
						//Economic cost-benefit calculation
						$("#eco-<?= $i; ?>").val($("#acnew-<?= $i; ?>").val()-$("#acold-<?= $i; ?>").val());


						//MArgianl-costs calculation
						//=EĞER(W3>0,M3/W3*100,-M3/W3*100)
						if($("#ecoben-<?= $i; ?>").val()>0){
							$("#marcos-<?= $i; ?>").val($("#eco-<?= $i; ?>").val()/$("#ecoben-<?= $i; ?>").val()*100);
							$("#marcos-<?= $i; ?>").val(toFixed($("#marcos-<?= $i; ?>").val(),2));
						}
						else{
							$("#marcos-<?= $i; ?>").val(-$("#eco-<?= $i; ?>").val()/$("#ecoben-<?= $i; ?>").val()*100);
							$("#marcos-<?= $i; ?>").val(toFixed($("#marcos-<?= $i; ?>").val(),2));
						}*/

					}

					function toFixed ( number, precision ) {
					    var multiplier = Math.pow( 10, precision + 1 ),
					        wholeNumber = Math.floor( number * multiplier );
					    return Math.round( wholeNumber / 10 ) * 10 / multiplier;
					}


					$('#form-<?= $i; ?> input').change(calculate);
 				</script>
				<?php $i++; ?>
				<!-- </form> -->
				<script type="text/javascript">	$( document ).ready(calculate);</script>
			<?php endforeach ?>
		<?php endif ?>
</div>
<div class="col-md-6" id="sag4">
	<p><?= lang("cbaheading3"); ?></p>
	<div id="rect-demo-ana" style="border:2px solid #f0f0f0;">
    <div id="rect-demo"></div>
  </div>
</div>
<?php
	//array defining
	$t=0;
	$toplameco=0;
    $alloc = $allocation;

    #sorts the allocation by marcos-1 ascending (lowest value first)
    usort($alloc, function($a, $b) {
        return $a['marcos-1'] <=> $b['marcos-1'];
    });

    if(isset($a) && is_numeric($a['sum-3-2'])) {
    	foreach ($alloc as $a) {
    		if(empty($a['cmpny_from_name'])) { $tuna_array[$t]['name']=$a['best']."-".$a['prcss_name'];} else {$tuna_array[$t]['name']=$a['flow_name']." input IS potential from/to ".$a['cmpny_from_name']; }
    		
    		$tuna_array[$t]['color']='#' . str_pad(dechex(mt_rand(0, 0xFFFFFF)), 6, '0', STR_PAD_LEFT);
    		if($a['marcos-1']>0){
    			$tuna_array[$t]['ymax']= floatval($a['marcos-1']);
    		}
    		else{
    			$tuna_array[$t]['ymax']= 0;
    		}

    		$toplameco+=$a['sum-3-2'];
    		$tuna_array[$t]['xmax']= floatval($a['sum-3-2']);

    		$eksieco = $toplameco - floatval($a['sum-3-2']);
    		$tuna_array[$t]['xmin']= $eksieco;

    		if($a['marcos-1']>0){
    			$tuna_array[$t]['ymin']= "0";
    		}
    		else{
    			$tuna_array[$t]['ymin']= floatval($a['marcos-1']);
    		}
    		$t++;
    	}
    }
?>
<script type="text/javascript">
	setTimeout(function()
	{  
		tuna_graph();
	}, 1000);

	function tuna_graph(){
	//console.log(list);
	//Tuna Graph
	var data = <?= json_encode($tuna_array); ?>;
	var margin = {
	            "top": 10,
	            "right": 30,
	            "bottom": 350,
	            "left": 50
	        };
	var width = $('#sag4').width()-80;
	var height = 500;
	// Set the scales
  var x = d3.scale.linear()
          .domain([0, d3.max(data, function(d) { return d.xmin+d.xmax; })])
      		.range([0,width]).nice();

  var y = d3.scale.linear()
      		.domain([d3.min(data, function(d) { return d.ymin-0.1; }), d3.max(data, function(d) { return d.ymax; })])
      		.range([height, 0]).nice();

  var xAxis = d3.svg.axis().scale(x).orient("bottom");
  var yAxis = d3.svg.axis().scale(y).orient("left");

	// Create the SVG 'canvas'
  var svg = d3.select("#rect-demo-ana").append("svg")
          .attr("class", "chart")
          .attr("mousewheel.zoom", null)
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom).append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.right + ")");

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0,"+ y(0) +")")
    .call(xAxis);

  svg.append("g")
    .attr("class", "y axis")
    .call(yAxis);

  //x axis label
	svg.append("text")
		.attr("transform", "translate(" + (width / 2) + " ," + (height + margin.bottom - 305) + ")")
		.style("text-anchor", "middle")
		.text("<?= lang('ecologicalbenefit'); ?> (EP/a)");

	//y axis label
	svg.append("text")
		.attr("transform", "rotate(-90)")
		.attr("y", 0 - margin.left)
		.attr("x", 0 - (height / 2))
		.attr("dy", "1em")
		.style("text-anchor", "middle")
		.text("<?= lang('marginalcost'); ?> (<?= $allocation[0]['unit_cost']; ?>/EP)");

	svg.selectAll("rect").
		data(data).
		enter().
		append("svg:rect").
		attr("x", function(datum,index) { return x(datum.xmin); }).
		attr("y", function(datum,index) { return y(datum.ymax); }).
		attr("height", function(datum,index) { return y(datum.ymin)-y(datum.ymax)+(height*0.0001); }).
		attr("width", function(datum, index) { return x(datum.xmax)+(width*0.0001); })
		.attr("fill", function(d, i) { return d.color; })
		.style("opacity", '0.5')
		.on("mouseover", function(datum,index){return tooltip.style("visibility", "visible").html(datum.name);})
		.on("mousemove", function(datum,index){return tooltip.style("top", (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px").html(datum.name);})
		.on("mouseout", function(){return tooltip.style("visibility", "hidden");});

		var tooltip = d3.select("body")
		.append("div")
		.style("position", "absolute")
		.style("z-index", "10")
		.style("visibility", "hidden")
		.style("background-color", "white")
		.style("padding", "10px")
		.style("border", "1px solid #d0d0d0")
		.style("border-radius", "2px")
		.style("font-size", "12px")
		.style("max-width", "200px")
		.style("color", "#444");

		// add legend   
		var legend = svg.append("g")
	  .attr("class", "legend")
        //.attr("x", w - 65)
        //.attr("y", 50)
	  .attr("height", 100)
	  .attr("width", 100)
    .attr('transform', 'translate(-20,50)')    
      
    legend.selectAll('rect')
      .data(data)
      .enter()
      .append("circle")
      .attr("r", 7)
      .attr("cx", 1)
      .attr("cy", function(d, i){ return 555 + (i *  19);})
		  .style("fill", function(datum,index) { return datum.color; })
		 	.style("opacity", '0.5')
      
    legend.selectAll('text')
      .data(data)
      .enter()
      .append("text")
		.style("font-size", "12px")
	  .attr("x", 16)
    .attr("y", function(d, i){ return i *  19 + 559;})
	  .text(function(datum,index) { return datum.name; });

	  svg.call(
	  	d3.behavior.zoom()
	  	.x(x).y(y).on("zoom", zoom)
	  	);
 
		function zoom() {
		  svg.select(".x.axis").call(xAxis);
		  svg.select(".y.axis").call(yAxis);
		  svg.selectAll('rect').attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
		}
	}
</script>
<?php $k=1; ?>

<?php foreach ($allocation as $b): ?>
<script type="text/javascript">
    //insert the first (predefined) row if it has empty flow name or value. 
    //Eg. if the user deletes this values they are reentered automatically
    var flownamedef= "<?= $b['flow_name']; ?>";
    var qntty_unit= "<?= $b['qntty_unit']; ?>";
    var amount= "<?= $b['amount']; ?>";
    var cost= "<?= $b['cost']; ?>";
    var env_impact= "<?= $b['env_impact']; ?>";
    var k= <?= $k; ?>;
    
    if(document.getElementById('flow-name-1-'+k).value=="" || document.getElementById('flow-value-1-'+k).value==""){
        document.getElementById('flow-name-1-'+k).value = flownamedef;
        document.getElementById('flow-unit-1-'+k).value = qntty_unit;
        document.getElementById('flow-value-1-'+k).value = amount;
        document.getElementById('flow-specost-1-'+k).value = cost/amount;
        document.getElementById('flow-eipunit-1-'+k).value = env_impact/amount;
    }

    //inserts the values on the option side if the value is empty
    if(document.getElementById('flow-name-2-'+k).value=="" || document.getElementById('flow-value-2-'+k).value==""){
        document.getElementById('flow-name-2-'+k).value = flownamedef;
        document.getElementById('flow-unit-2-'+k).value = qntty_unit;
        document.getElementById('flow-value-2-'+k).value = amount;
        document.getElementById('flow-specost-2-'+k).value = cost/amount;
        document.getElementById('flow-eipunit-2-'+k).value = env_impact/amount;
    }

</script>

<script type="text/javascript">
function insertFlowRow(selectedObject) {
    //gives the selected flow_id from the select dropdown
    var selected_id = selectedObject.value;

    //gets the unique "key" for this table row
    var table_key = $(selectedObject).attr('id').slice(-5);
    var form_num = $(selectedObject).attr('id').slice(-1);

    //gets the cmpny flow array as json in JS
    var flow_array = <?= json_encode($allocated_flows); ?>;

    //loops through all flows and gets the one that is selected
    for (flow in flow_array){
        if (flow_array[flow]['allocation_id'] == selected_id){
            //inserts the flow values in the row (baseline)
            $('#flow-name-'+table_key).val(flow_array[flow]['flow_name'] +" ("+ flow_array[flow]['flow_type_name']+")");
            $('#flow-value-'+table_key).val(flow_array[flow]['amount']);
            $('#flow-unit-'+table_key).val(flow_array[flow]['unit_amount']);
            $('#flow-specost-'+table_key).val(flow_array[flow]['cost']/flow_array[flow]['amount']);
            $('#flow-eipunit-'+table_key).val(flow_array[flow]['env_impact']/flow_array[flow]['amount']);


            if (confirm("Values will be inserted as baseline on the left. \nDo you want to use the same values as option on the right side aswell? Your are able to change them as you want.")) {
                //if confirmed same values used as option, inserts the flow values in the row 
                $('#flow-name-2'+table_key.slice(-4)).val(flow_array[flow]['flow_name'] +" ("+ flow_array[flow]['flow_type_name']+")");
                $('#flow-value-2'+table_key.slice(-4)).val(flow_array[flow]['amount']);
                $('#flow-unit-2'+table_key.slice(-4)).val(flow_array[flow]['unit_amount']);
                $('#flow-specost-2'+table_key.slice(-4)).val(flow_array[flow]['cost']/flow_array[flow]['amount']);
                $('#flow-eipunit-2'+table_key.slice(-4)).val(flow_array[flow]['env_impact']/flow_array[flow]['amount']);

                $('#flow-name-3'+table_key.slice(-4)).val(flow_array[flow]['flow_name'] +" ("+ flow_array[flow]['flow_type_name']+")");
                 $('#flow-unit-3'+table_key.slice(-4)).val(flow_array[flow]['unit_amount']);
            } else {
                //empties the values on the option side
                $('#flow-name-2'+table_key.slice(-4)).val("");
                $('#flow-value-2'+table_key.slice(-4)).val("");
                $('#flow-unit-2'+table_key.slice(-4)).val("");
                $('#flow-specost-2'+table_key.slice(-4)).val("");
                $('#flow-eipunit-2'+table_key.slice(-4)).val("");

                $('#flow-name-3'+table_key.slice(-4)).val("");

            }
            //runs a change so that the values are calculated
            $('#form-'+form_num+' input').change();
            break;
        }
    }
} 

//tooltip unit column (option side)
$('.tooltip-unit').tooltip({
    position: 'top',
    content: '<span style="color:#fff"><?= lang("unit-ttip"); ?></span>',
    onShow: function(){
        $(this).tooltip('tip').css({
            backgroundColor: '#999',
            borderColor: '#999'
        });
    }
});
</script>
<?php $k=$k+1; ?>
<?php endforeach ?>