package Esv::Plugin::FormHtml;
use Mojo::Base 'Mojolicious::Plugin';

use MIME::Base64 qw(encode_base64url decode_base64url);
use HTTP::BrowserDetect;
use Mojo::Util qw(xml_escape);

use Esv::Ural::Changelog;


sub register {
  my ( $self, $app, $args ) = @_;
  $args ||= {};

  # html_or_undef = check_newversion
  $app->helper(check_newversion => sub {
    my $c = shift;
    my $coo = $c->cookie('version');
    my $cur_version = $c->stash('version');
    if (defined $coo) {
      if ($coo ne $cur_version) {
        $c->cookie(version => $cur_version, {path => '/', expires=>time+360000000});
        if (my $changelog = Esv::Ural::Changelog->new($c->app->config, $cur_version)) {
	  return '<div id="newversion-modal" class="modal modal-fixed-footer">
<div class="modal-content"><h4>Новая версия '.$changelog->get_version.
'</h4><p><b>Последние улучшения и новинки:</b></p>'.$changelog->get_changelog_html.
'</div><div class="modal-footer"><a href="#!" class="modal-close waves-effect waves-green btn-flat">Отлично</a></div></div>';
	}
      }
    } else {
      $c->cookie(version => $cur_version, {path => '/', expires=>time+360000000});
    }
    return undef;
  });


  # html_or_undef = check_browser
  $app->helper(check_browser => sub {
    my $c = shift;
    my $coo = $c->cookie('browser');
    if (!defined $coo || $coo ne '1') {
      $c->cookie(browser => 1, {path => '/'});
      my $ua = HTTP::BrowserDetect->new($c->req->headers->user_agent);
      #say "BROWSER CHECK!!!";
      if ($ua->ie && $ua->browser_major < 11) {
        return '<div id="oldbrowser-modal" class="modal modal-fixed-footer">
<div class="modal-content red lighten-1"><h5 class="white-text">Неподдерживаемый Интернет броузер</h5>
<p class="white-text"><b>ВНИМАНИЕ!</b></p>
<p class="white-text">Вы используете устаревшую версию броузера Интернет.
Многие элементы страницы будут отображены некорректно.</p>
<p class="white-text"><b>Обновите версию Вашего броузера!</b></p>
<p class="grey-text text-lighten-2">Системная информация'.
'<br>Броузер: '.(($ua->browser_string) ? xml_escape($ua->browser_string) : 'не определено').
'<br>Версия: '.(($ua->browser_version) ? xml_escape($ua->browser_version) : 'не определено').
'<br>Операционная система: '.(($ua->os_string) ? xml_escape($ua->os_string) : 'не определено').
'</p></div><div class="modal-footer"><a href="#!" class="modal-close waves-effect waves-green btn-flat">Закрыть</a></div></div>';
      }
    }
    return undef;
  });


  # 1_or_undef = check_newfeature(feature_no, feature_version)
  # current features:
  # 1 - print button help
  # 2 - main menu button
  $app->helper(check_newfeature => sub {
    my ($c, $fid, $fver) = @_;
    $fver = 1 unless defined $fver;
    my $coo_name = "feature$fid";
    my $coo = $c->cookie($coo_name);
    if (!defined $coo || $coo ne $fver) {
      $c->cookie($coo_name => $fver, {path => '/', expires=>time+360000000});
      return 1;
    }
    return undef;
  });


  # $id = metric2id('my.metric')
  $app->helper(metric2id => sub {
    my ($c, $id) = @_;
    my $s = $c->stash('idslt');
    unless ($s) {
      $s = [ chr(int(rand(26))+97), int(rand(900))+100 ];
      $c->stash(idslt => $s);
    }
    $id = $s->[1].$id;
    return $s->[0].encode_base64url($id, '');
  });

  # $metric = id2metric($id)
  $app->helper(id2metric => sub {
    my ($c, $id) = @_;
    $id = decode_base64url(substr $id, 1);
    return substr $id, 3;
  });


  # $code = form_el(class=>'textcb', metric=>'my.metric')
  # $code = form_el(class=>'textcb', metric=>'my.metric', style=>'norm'/'large'/'small'/'smallinline', unit=>'span'/'label'/'no')
  $app->helper(form_el => sub {
    my ($c, %args) = @_;
    my $metric = $args{metric};

    my $met_conf = $c->metric_catalog->get_metric($metric);
    my $id = $c->metric2id($metric);
    my $v = $c->stash('mb')->get($metric);

    my $ul = '';
    my $sp = $met_conf->{unit};
    if (defined $args{unit}) {
      if ($args{unit} eq 'label') {
	$ul = ", $met_conf->{unit}" if $met_conf->{unit};
	$sp = '';
      } elsif ($args{unit} eq 'no') {
	$sp = '';
      }
    }
    my $input_field_class = '';
    my $input_class = '';
    my $label = "<label for=\"$id\">$met_conf->{form_label}$ul</label>";
    my $placeholder = 'новое';
    if (defined $args{style}) {
      if ($args{style} eq 'norm') {
	$input_field_class = 'norm-input-field';
	$input_class = 'norm-input';
      } elsif ($args{style} eq 'small') {
	$input_field_class = 'small-input-field';
	$input_class = 'small-input';
	$label = '';
        $placeholder = '';
      } elsif ($args{style} eq 'smallinline') {
	$input_field_class = 'small-input-field inline';
	$input_class = 'small-input';
	$label = '';
        $placeholder = '';
      }
    }
    return "<div class=\"input-field $input_field_class\"><input class=\"$args{class} $input_class\" id=\"$id\" type=\"text\" placeholder=\"$placeholder\" value=\"$v\">\
$label<span class=\"helper-text\">$sp</span></div>";
  });


  # $code = form_maxmin_el(class=>'maxmincb', metric_max=>'my.metric.max', metric_min=>'my.metric.min', style=>'norm'/'large'/'small', unit=>'span'/'no')
  $app->helper(form_maxmin_el => sub {
    my ($c, %args) = @_;
    my $metric_max = $args{metric_max};
    my $metric_min = $args{metric_min};
    my $metmin_conf = $c->metric_catalog->get_metric($metric_min);
    my $metmax_conf = $c->metric_catalog->get_metric($metric_max);
    my $id = $c->metric2id($metric_max.'&'.$metric_min);
    my $v = $c->stash('mb')->get($metric_max, $metric_min);

    my $sp = $metmax_conf->{unit};
    if (defined $args{unit}) {
      if ($args{unit} eq 'no') {
	$sp = '';
      }
    }
    my $input_field_class = '';
    my $input_class = '';
    my $label = "<label for=\"$id\">$metmax_conf->{form_label}</label>";
    my $placeholder = 'мин-макс';
    my $title = '';
    if (defined $args{style}) {
      if ($args{style} eq 'norm') {
	$input_field_class = 'norm-input-field';
	$input_class = 'norm-input';
      } elsif ($args{style} eq 'small') {
	$input_field_class = 'small-input-field';
	$input_class = 'small-input';
	$label = '';
	#$placeholder = '';
        $title = "title=\"$metmax_conf->{form_label}\"";
      }
    }
    return "<div class=\"input-field $input_field_class\"><input class=\"$args{class} $input_class\" id=\"$id\" type=\"text\" placeholder=\"$placeholder\" value=\"$v\" $title>\
$label<span class=\"helper-text\">$sp</span></div>";
  });


  # $code = form_formula_el(id=>'unique-element-id', style=>'norm'/'large'/'small', font=>'small')
  # $code = form_formula_el(id=>'unique-element-id', label=>'Label Text')
  # $code = form_formula_el(id=>'unique-element-id', label=>'Label Text', span=>'Span Text')
  $app->helper(form_formula_el => sub {
    my ($c, %args) = @_;
    my $sp = $args{span};
    $sp = '' unless defined $sp;

    my $label = (defined $args{label}) ? "<label for=\"$args{id}\">$args{label}</label>" : '';

    my $input_field_class = '';
    my $input_class = '';
    if (defined $args{style}) {
      if ($args{style} eq 'norm') {
	$input_field_class = 'norm-input-field';
	$input_class = 'norm-input';
      } elsif ($args{style} eq 'small') {
	$input_field_class = 'small-input-field';
        my $fnt = (defined $args{font} && $args{font} eq 'small') ? ' small-font' : '';
	$input_class = 'small-input'.$fnt;
      }
    }
    return "<div class=\"input-field $input_field_class\"><input class=\"$input_class\" id=\"$args{id}\" type=\"text\" value=\"\" disabled>\
$label<span class=\"helper-text\">$sp</span></div>";
  });


  # $code = form_sost_lgosk_el(class=>'textcb', metric=>'my.metric')
  $app->helper(form_sost_lgosk_el => sub {
    my ($c, %args) = @_;
    my $metric = $args{metric};
    my $met_conf = $c->metric_catalog->get_metric($metric);
    my $id = $c->metric2id($metric);
    my $v = $c->stash('mb')->get($metric);
    $v = -1 if $v eq '';
    my @opt_list = ('РАБОТА', 'ТО', 'Резерв', 'Ремонт');
    my $r = '<div class="input-field">';
    $r .= "<select class=\"$args{class}\" id=\"$id\">";
    for (0 .. $#opt_list) {
      $r .= '<option value="'.$_.'"'.(($v==$_)?' selected':'').'>'.$opt_list[$_].'</option>';
    }
    $r .= '<option value="" disabled'.(($v<0 || $v>$#opt_list)?' selected':'').'>Не выбрано</option>';
    $r .= '</select>';
    $r .= "<label for=\"$id\">$met_conf->{form_label}</label>";
    #$r .= "<span class=\"helper-text\">$met_conf->{unit}</span></div>";
    $r .= "<span class=\"helper-text\"></span></div>";
    return $r;
  });


  # $code = form_date_el(class=>'datecb', metric=>'my.metric', style=>'norm'/'large'/'small', unit=>'span'/'no')
  $app->helper(form_date_el => sub {
    my ($c, %args) = @_;
    my $metric = $args{metric};
    my $met_conf = $c->metric_catalog->get_metric($metric);
    my $id = $c->metric2id($metric);
    my $v = $c->stash('mb')->get($metric);

    my $sp = $met_conf->{unit};
    if (defined $args{unit}) {
      if ($args{unit} eq 'no') {
	$sp = '';
      }
    }
    my $input_field_class = '';
    my $input_class = '';
    my $label = "<label for=\"$id\">$met_conf->{form_label}</label>";
    my $placeholder = 'новое';
    if (defined $args{style}) {
      if ($args{style} eq 'norm') {
        $input_field_class = 'norm-input-field';
        $input_class = 'norm-input';
      } elsif ($args{style} eq 'small') {
	$input_field_class = 'small-input-field';
	$input_class = 'small-input';
	$label = '';
        $placeholder = 'дд.мм.гггг';
      }
    }
    return "<div class=\"input-field $input_field_class\"><input class=\"datepicker $args{class} $input_class\" id=\"$id\" type=\"text\" placeholder=\"$placeholder\" value=\"$v\">\
$label<span class=\"helper-text\">$sp</span></div>";
  });


}

1;
__END__
