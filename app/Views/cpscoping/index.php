<script type="text/javascript">
    $(document).ready(function() {
        $("#projects").change(function() {         
            var secim = $( "#projects" ).val();
            $('#companiess').children().remove();
            $.ajax({ 
                type: "POST",
                dataType:'json',
                url: '<?= base_url('cpscoping/pro'); ?>/'+secim, 
                success: function(data)
                {
                    $('#companiess').append('<option value="0">Nothing Selected</option>');
                    for(var k = 0 ; k < data.length ; k++){
                        $('#companiess').append('<option value="'+data[k].id+'">'+data[k].name+'</option>');
                    }
                }
            });
        });
        $("#companiess").change(function() {         
            var pro = $( "#projects" ).val();
            var com = $( "#companiess" ).val();
            $("#cpscopinga").attr("href", '<?= base_url('cpscoping'); ?>/'+pro+'/'+com+'/allocation');
        });
    });
</script>


<div class="col-md-3">
    <p><?= lang("Validation.cpheading"); ?></p>
    <!--
    <select id="projects" class="btn-group select select-block">
        <option value="0">Nothing Selected</option>
        <?php foreach ($c_projects as $p): ?>
            <option value="<?= $p['proje_id']; ?>"><?= $p['name']; ?></option>
        <?php   endforeach  ?>
    </select>
    <select id="companiess" class="btn-group select select-block">
        <option value="0">Nothing Selected</option>
    </select>
    <a href="#" class="btn btn-default btn-sm" id="cpscopinga">New CP potentials identification</a>-->
    <div><?= lang("Validation.companiesunder"); ?> <?= session()->project_name['name']; ?></div><br>
    <?php foreach ($com_pro as $cp): ?>
        <div class="boxhead"><?= $cp['company_name']; ?></div>
        <div class="boxcontent">
            <a href="<?= base_url('cpscoping/'.session()->project_name['id'].'/'.$cp['company_id'].'/allocation'); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga"><?= lang("Validation.createallocation"); ?></a>
            <a href="<?= base_url('new_flow/'.$cp['company_id']); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga"><?= lang("Validation.datasetmanagement"); ?></a>
        </div>
    <?php endforeach ?><br>
</div>

<div class="col-md-9">
    <p><?= lang("Validation.cpheading2"); ?></p>
    <?php $i = 0; ?>
    <?php foreach ($com_pro as $cp): ?>
        <?php // print_r($cp); ?>
        <?php if(sizeof($flow_prcss[$i])>0): ?>
        <div class="cp-heading">
            <div class="row">
                <div class="col-md-12"><a href="<?= base_url('company/'.$cp['company_id']); ?>"><?= $cp['company_name']; ?></a></div>
            </div>
        </div>
        <div class="cp-bar">
            <a style="margin-right:10px;" href="<?= base_url('cpscoping/'.$cp['project_id'].'/'.$cp['company_id'].'/show'); ?>" class=" btn-sm btn-info"><?= lang("Validation.viewcp"); ?></a>
            <a style="margin-right:10px;" href="<?= base_url('kpi_calculation/'.$cp['project_id'].'/'.$cp['company_id']); ?>" class=" btn-sm btn-success"><?= lang("Validation.viewkpi"); ?></a>
            <a href="<?= base_url('cost_benefit/'.$cp['project_id'].'/'.$cp['company_id']); ?>" class=" btn-sm btn-warning"><?= lang("Validation.viewcba"); ?></a>
        </div>
        <table class="table table-striped" style="font-size:12px;">
            <tr>
                <th style="width: 500px;"><?= lang("Validation.processname"); ?></th>
                <th style="width: 400px;"><?= lang("Validation.flowname"); ?></th>
                <th style="width: 200px;"><?= lang("Validation.flowtype"); ?></th>
                <th><?= lang("Validation.manage"); ?></th>
            </tr>
        <?php endif ?>
        <?php for($k = 0 ; $k < sizeof($flow_prcss[$i]) ; $k++): ?>
            <?php //print_r($flow_prcss[$i][$k]); ?>
            <tr>
                <td><?= $flow_prcss[$i][$k]['prcss_name']; ?></td>
                <td><?= $flow_prcss[$i][$k]['flow_name']; ?></td>
                <td><?= $flow_prcss[$i][$k]['flow_type_name']; ?></td>
                <td>
                    <a class="label label-info" href="<?= base_url('cpscoping/edit_allocation/'.$flow_prcss[$i][$k]['allocation_id']); ?>"><?= lang("Validation.editallocation"); ?></a>
                    <a class="label label-danger" href="<?= base_url('cpscoping/delete/'.$flow_prcss[$i][$k]['allocation_id'].'/'.$flow_prcss[$i][$k]['project_id'].'/'.$flow_prcss[$i][$k]['company_id']); ?>" 
                        onclick="return confirm('Are you sure you want to delete the allocation <?= $flow_prcss[$i][$k]['prcss_name']; ?>?');"><?= lang("Validation.deleteallocation"); ?></a></td>
            </tr>   
        <?php endfor ?>
        </table>
        <?php $i++; ?>
    <?php endforeach ?>
</div>