<div class="container">
    <p></p>
    <h4>Project Companies <p><?= lang("Validation.cbaheading4"); ?></p></h4>
    <div><?= lang("Validation.cbadesc"); ?></div>
    <table style="margin-top:10px; width:100%;">
    <?php foreach ($com_pro as $cp): ?>
        <tr >
            <td>
                <a href="<?= base_url('cost_benefit/'.session()->project_id.'/'.$cp['id']); ?>/" class=""><?= $cp['name']; ?></a>
            </td>
        </tr>
    <?php endforeach ?>
    </table>
</div>