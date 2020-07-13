$(document).on('click', ".export_option", function(event){
  event.stopPropagation();
  const id = $(this).closest(".library-table").find("table").eq(0).attr('id');
  if($(this).text().trim() === "csv") {
    $(this).attr({ 'download': "output.csv", 'href': export_table(id, $(this).text().trim()), 'target': '_blank' });
  } else if($(this).text().trim() === "txt") {
    $(this).attr({ 'download': "output.txt", 'href': export_table(id, $(this).text().trim()), 'target': '_blank' });
  } else if($(this).text().trim() === "excel") {
    $(this).attr({ 'download': "output.xls", 'href': export_table(id, $(this).text().trim()), 'target': '_blank' });
  }
  $(this).closest('.export').eq(0).removeClass("open");
});





async function export_table(id, type) {
  const table = $('#'+id);
  const side = $(table).data('side');
  const header = table.find("tr:has(th)").eq(0).find(".header-item:not(.header-checkbox)");
  let rows = [];
  if(side === "client") {
    if($('#' + id + '_export_checkbox').is(':checked')) {
      rows = table.find(".row-checked:has(td)");
    } else {
      rows = table.find("tr:has(td)");
    }
    let csv = "";
    for(let cell of header){
      csv = csv + $(cell).find(".header-text").text().replace(/,/g, '') + ",";
    }
    csv = csv + '\n';
    for(let row of rows){
      for(let c of $(row).find(".row-item")) {
        if($(c).hasClass("action-column")) {
          continue;
        } else if($(c).hasClass("checkmark-column")) {
          csv = csv + (($(c).find(".cell-text i").css("visibility") == "visible")? "Yes,": "No,");
        } else {
          csv = csv + $(c).find(".cell-text").text().replace(/,/g, '') + ",";
        }
      }
      csv = csv + '\n';
    }    
  } else {
    let csv = "";
    let data = {'page': 0, 'page_size': 22222, 'search': $('#'+id).siblings(".function_bar").find(".searchbar").val()}; // 22222 page size is meant to include all of the rows, ugly hack
    sorted_column = $(header).children(".sorted");
    data['sort_column'] = $(sorted_column).attr("code");
    data['sort_order'] = ($(sorted_column).hasClass("sorted-desc")) ? "descending": "ascending";
    await $.ajax({
      type: "GET",
      contentType: "application/json; charset=utf-8",
      url: url,
      data : data,
      dataType: "json",
      success: (d, s, xhr)=> {
        response = d;
      },
      complete: (jqXHR, status) => {  
        let rows = [];
        if(status == 'success') {
          r = response;
          r_columns = Object.keys(r['rows'][0]); 
          for(let [index,obj] of r['rows'].entries()) {
            let row = {};
            let columns = Object.keys(obj);
            for(let col of columns) {
              row[col] = obj[col]["data"];
            }
            rows.append(row);
          }
        }
        console.log(rows);
      },
      error: function (e){
          console.log(e);
          return -1;
      }
    });
  }



  if(type === "csv") {
    csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);
    return csvData;
  } else if(type === "txt") {
    csvData = 'data:application/txt;charset=utf-8,' + encodeURIComponent(csv);
    return csvData;
  } else if(type === "excel") {
    csvData = 'data:application/xls;charset=utf-8,' + encodeURIComponent(csv);
    return csvData;
  }
  
}

function init_export(id, types) {
  const table = $('#'+id);
  $(document).ready(function(){
    let wrapper = $('<div class="export">');
    let button = $('<div class=" function_button export_button">').append('<i class="fas fa-file-download button-label button-icon" aria-hidden="true">');
    let options = $('<div class="export_options">');
    let selected_rows_checkbox = $('<div class="selected_rows_checkbox_wrapper">').append($('<input type="checkbox" class="selected_rows_checkbox" id="' + id + '_export_checkbox">')).append($('<label class="selected_rows_checkbox_label" for="' + id + '_export_checkbox">').text("Selected Rows Only"));
    $(document).on('click', ".export", function(event){
      event.stopPropagation();
      event.stopImmediatePropagation();
      $(this).toggleClass("open");
    });
    options.append($('<div class="export_label">').text("Export Data"));
    options.append(selected_rows_checkbox);
    for(let type of types){
      options.append($('<a class="export_option">').text(type).prepend('<i class="fas fa-file-download button-label button-icon" aria-hidden="true">'));
    }
    wrapper.append(button).append(options);
    table.parent().find(".function_bar").append(wrapper);
    
  });
}


// close on click away
$(document).on('click', function(e){
  if($(e.target).closest('.open').length === 0) {
    $('.open').removeClass('open');
  }
});