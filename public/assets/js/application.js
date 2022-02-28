// Some general UI pack related JS
// Extend JS String with repeat method
String.prototype.repeat = function(num) {
  return new Array(num + 1).join(this);
};

(function($) {

  // Add segments to a slider
  $.fn.addSliderSegments = function (amount, orientation) {
    return this.each(function () {
      if (orientation == "vertical") {
        var output = ''
          , i;
        for (i = 1; i <= amount - 2; i++) {
          output += '<div class="ui-slider-segment" style="top:' + 100 / (amount - 1) * i + '%;"></div>';
        };
        $(this).prepend(output);
      } else {
        var segmentGap = 100 / (amount - 1) + "%"
          , segment = '<div class="ui-slider-segment" style="margin-left: ' + segmentGap + ';"></div>';
        $(this).prepend(segment.repeat(amount - 2));
      }
    });
  };

  $(function() {

    // Custom Selects
    $("select[id='huge']").selectpicker({style: 'btn-hg btn-primary', menuStyle: 'dropdown-inverse'});
    $("select[id='large']").selectpicker({style: 'btn-lg btn-danger'});
    $("select[class='info']").selectpicker({style: 'btn-inverse'});
    $("select[id='status']").selectpicker({style: 'btn-default'});
    $("select[id='small']").selectpicker({style: 'btn-sm btn-inverse'});
    $("select[id='projects']").selectpicker({style: 'btn-sm btn-inverse'});
    $("select[id='companiess']").selectpicker({style: 'btn-sm btn-inverse'});
    
    //selects all SELECT elements without the ones has seletize id.
    $("select:not([id^=selectize])").selectpicker({style: ' btn-inverse'});


    // Tabs
    $(".nav-tabs a").on('click', function (e) {
      e.preventDefault();
      $(this).tab("show");
    })

    // Tags Input
    $(".tagsinput").tagsInput();

    // Add style class name to a tooltips
    $(".tooltip").addClass(function() {
      if ($(this).prev().attr("data-tooltip-style")) {
        return "tooltip-" + $(this).prev().attr("data-tooltip-style");
      }
    });

    // Placeholders for input/textarea
    $(":text, textarea").placeholder();

    // Make pagination demo work
    $(".pagination").on('click', "a", function() {
      $(this).parent().siblings("li").removeClass("active").end().addClass("active");
    });

    $(".btn-group").on('click', "a", function() {
      $(this).siblings().removeClass("active").end().addClass("active");
    });

    // Disable link clicks to prevent page scrolling
    $(document).on('click', 'a[href="#fakelink"]', function (e) {
      e.preventDefault();
    });

    // Focus state for append/prepend inputs
    $('.input-group').on('focus', '.form-control', function () {
      $(this).closest('.input-group, .form-group').addClass('focus');
    }).on('blur', '.form-control', function () {
      $(this).closest('.input-group, .form-group').removeClass('focus');
    });

    // Table: Toggle all checkboxes
    $('.table .toggle-all').on('click', function() {
      var ch = $(this).find(':checkbox').prop('checked');
      $(this).closest('.table').find('tbody :checkbox').checkbox(!ch ? 'check' : 'uncheck');
    });

    // Table: Add class row selected
    $('.table tbody :checkbox').on('check uncheck toggle', function (e) {
      var $this = $(this)
        , check = $this.prop('checked')
        , toggle = e.type == 'toggle'
        , checkboxes = $('.table tbody :checkbox')
        , checkAll = checkboxes.length == checkboxes.filter(':checked').length

      $this.closest('tr')[check ? 'addClass' : 'removeClass']('selected-row');
      if (toggle) $this.closest('.table').find('.toggle-all :checkbox').checkbox(checkAll ? 'check' : 'uncheck');
    });

    // Switch
    $("[data-toggle='switch']").wrap('<div class="switch" />').parent().bootstrapSwitch();

    // Typeahead
    if($('#typeahead-demo-01').length) {
      $('#typeahead-demo-01').typeahead({
        name: 'states',
        limit: 4,
        local: ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut",
        "Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky",
        "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri",
        "Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Dakota",
        "North Carolina","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina",
        "South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
      });
    }

    // make code pretty
    window.prettyPrint && prettyPrint();
  });
})(jQuery);
