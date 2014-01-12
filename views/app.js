$(function() {
  var trip = $('#_trip').text();
  var channel = $('#_channel').text();
  var fontsize = $('#_fontsize').text();
  var _coding = false;

  $('#_trip').remove();
  $('#_channel').remove();
  $('#_fontsize').remove();

  if (channel !== '') {
    var io = new RocketIO({ channel: channel }).connect();
    var hash = io.session;
  } else {
    var io = null;
    location.href = 'http://google.com/';
  }

  io.on('errored', function(data) {
    console.log('nyaaaaaa');
    console.log(data);
  });

  // クライアントの接続
  io.on('connect', function() {
    io.push('connected', { trip: trip });

    console.log('connect');
  });

  // 接続完了
  io.on('ready', function(data) {
    $('#user_name').text(data['name']);
    $('#user_image').attr('src', data['image_url']).css('border', data['color'] + ' 2px solid');
    $('#modal').hide();

    console.log('ready');
    console.log(data);
  });

  // disconnectは無し

  // チャットの送信
  $('#chat_input').keypress(function(e) {
    if (e.keyCode === 13) {
      io.push('message', {
        hash: hash,
        message: $(this).val()
      });

      $(this).val('').text('');
      return false;
    }
  });

  // チャットの受信
  io.on('message', function(data) {
    $('#chat_log').prepend(
      $('<div class="item"></div>').append(
        $('<img class="image">').attr('src', data['image_url']).css('border', data['color'] + ' 2px solid'),
        $('<div class="wrap"></div>').append(
          $('<div class="message"></div>').append(
            $('<span></span>').text(data['message']),
            $('<span class="posted"></span>').text(data['posted'])
          )
        )
      )
    );

    console.log('chat');
    console.log(data);
  });

  // コードの編集が開始された
  io.on('code_started', function(data) {
    _coding = true;
    $('#label_off').hide();
    $('#label_on_image').attr('src', data['image_url']);
    $('#label_on_name').text(data['name'] + 'が編集中...');
    $('#code_frame').css('border', data['color'] + ' 2px solid');
    $('#label_on').css('background-color', data['color']);
    $('#label_on').show();

    console.log('code_start');
    console.log(data);
  });

  // コードの編集が終了された
  io.on('code_finished', function(data) {
    _coding = false;
    $('#label_on').hide();
    $('#label_on').hide();
    $('#code_preview').text(data['code']).removeClass('prettyprinted');
    prettyPrint();
    $('#code_input').val(data['code']);
    $('#code_frame').css('border', '#666 2px solid');

    console.log('code_finished');
    console.log(data);
  });

  // コードが編集(キー入力)された
  io.on('code_changed', function(data) {
    _coding = true;
    $('#code_preview').text(data['code']).removeClass('prettyprinted');
    prettyPrint();
    console.log('code_changed');
    console.log(data);
  });

  // コードの編集を開始した
  $('#label_off').click(function() {
    _coding = true;
    $('#label_on').show();
    $('#label_off').hide();
    $('#code_preview').hide();
    $('#code_input').show();
    $('#code_input').focus();

    io.push('code_start', { hash: io.session });
  });

  // コードの編集を終了した
  $('#code_input').blur(function() {
    io.push('code_finish', {code: $('#code_input').val()});

    _coding = false;
    $('#label_on').hide();
    $('#code_preview').text($('#code_input').val()).removeClass('prettyprinted').show();
    $('#code_input').hide();
    prettyPrint();
  });

  // コードの編集中、キー入力された
  $('#code_input').keyup(function() {
    io.push('code_change', {code: $('#code_input').val()});
  });

  // Tabキー入力
  $('#code_input').keydown(function(e) {
    if (e.keyCode === 9) {
      var obj = $(this).get(0),
          pos = obj.selectionStart,
          val = obj.value;
      obj.value = val.substr(0, pos) + '    ' + val.substr(pos);
      obj.setSelectionRange(pos + 4, pos + 4);

      return false;
    }
  });

  // ラベルを見せたり隠したり
  $('.code').hover(
    function() {
      if (!_coding) {
        $('#label_off').show();
      }
    },
    function() {
      if (!_coding) {
        $('#label_off').hide();
      }
    }
  );

  $('#open_fontsize').click(function() {
    $('#fontsize').val(fontsize - 0);
    $('#font_window').show();
  });

  $('#fontsize').change(function() {
    fontsize = $(this).val() - 0;
    $('#fontsize_preview').text('' + fontsize + 'px');
    $('body').css('font-size', '' + fontsize + 'px');
  })

  $('#close_fontsize').click(function() {
    $('#font_window').hide();
    io.push('fontsize', { fontsize: fontsize });
  });

  prettyPrint();
});
