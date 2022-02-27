<div class="col-md-4 col-md-offset-4">
    <p><?= lang("Validation.cbaheading4"); ?></p>
    <?php foreach ($com_pro as $cp): ?>
        <div class="">
            <a href="<?= base_url('cost_benefit/'.$this->session->userdata('project_id').'/'.$cp['id']); ?>/" class="btn btn-inverse"><?= $cp['name']; ?></a>
        </div>
    <?php endforeach ?><br>
    <div><?= lang("Validation.cbadesc"); ?></div>
</div>