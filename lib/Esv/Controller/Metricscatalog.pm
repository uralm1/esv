package Esv::Controller::Metricscatalog;
use Mojo::Base 'Mojolicious::Controller';

use POSIX qw(ceil);

sub index {
  my $self = shift;
  return undef unless $self->authorize($self->allow_all_roles);

  my $search = $self->param('s');
  my $active_page = $self->param('p') || 1;
  return $self->render(text => 'Ошибка') unless $active_page =~ /^\d+$/;

  my $m = $self->metric_catalog->get_metrics;
  my @metric_names = grep {($search) ? /\Q$search\E/ : 1} sort keys %$m;
  my $rec_page = 11;
  my $total_metrics = scalar(@metric_names);
  my $num_pages = ceil($total_metrics / $rec_page);

  $active_page = 1 if ($active_page < 1 || ($num_pages > 0 && $active_page > $num_pages));

  $self->render(
    search => $search,
    alltotal_metrics => scalar keys %$m,
    total_metrics => $total_metrics,
    start_index => ($active_page - 1) * $rec_page,
    metric_names => \@metric_names,
    rec_page => $rec_page,
    catalog_num_pages => $num_pages,
    catalog_active_page => $active_page,
  );
}

1;
