<div class="container">
    <div class="well">
    <p><?= lang("Validation.cbaheading4"); ?></p>
    <h4>Project Companies</h4>
    <p>Select a company to see its cost benefit analysis.</p>
    <?php foreach ($com_pro as $cp): ?>
        <div style="margin-bottom:10px;">
            <a href="<?= base_url('cost_benefit/'.session()->project_id.'/'.$cp['id']); ?>/" class=""><?= $cp['name']; ?></a>
        </div>
    <?php endforeach ?><br>
    <div><?= lang("Validation.cbadesc"); ?></div>
    </div>
</div>