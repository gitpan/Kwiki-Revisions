package Kwiki::Revisions;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';
our $VERSION = '0.11';

const class_id => 'revisions';
const class_title => 'Revisions';
const cgi_class => 'Kwiki::Revisions::CGI';
field revision_id => 0;

sub register {
    my $registry = shift;
    $registry->add(action => 'revisions');
    $registry->add(toolbar => 'revisions_button', 
                   template => 'revisions_button.html',
                   show_for => 'display',
                  );
    $registry->add(toolbar => 'revisions_controls', 
                   template => 'revisions_controls.html',
                   show_for => 'revisions',
                  );
}

sub revisions {
    $self->use_class('archive');
    my $page = $self->pages->current;
    $page->load;
    my $revision_id = $self->cgi->revision_id
      or return $self->redirect($page->id);
    $self->revision_id($revision_id);
    my $archive = $self->hub->load_class('archive');
    $page->content($archive->fetch($page, $revision_id));
    my ($metadata) = grep {
        $_->{revision_id} eq $revision_id;
    } @{$archive->history($page)};
    $page->metadata->edit_by($metadata->{edit_by});
    $page->metadata->edit_time($metadata->{edit_time});
    $page->metadata->edit_unixtime($metadata->{edit_unixtime});
    $self->page($page);
    $self->render_screen(
        screen_title => $page->id,
        page_html => $page->to_html,
        revision_id => $revision_id,
        revision_top => $page->revision_number,
    );
}

package Kwiki::Revisions::CGI;
use Kwiki::CGI '-base';

cgi 'revision_id';

1;

package Kwiki::Revisions;
__DATA__

=head1 NAME 

Kwiki::Revisions - Kwiki Revisions Plugin

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Brian Ingerson <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
__template/tt2/revisions_button.html__
<!-- BEGIN revisions_button.html -->
[% revision_number = hub.pages.current.revision_number %]
[% IF revision_number > 1 %]
<a href="[% script_name %]?action=revisions&page_id=[% page_id %]&revision_id=[% revision_number - 1 %]" accesskey="r" title="[% revision_number %] Revisions - Link to Previous">
[% INCLUDE revisions_button_icon.html %]
</a>
[% END %]
<!-- END revisions_button.html -->
__template/tt2/revisions_button_icon.html__
<!-- BEGIN revisions_button_icon.html -->
[% revision_number %]&nbsp;Revisions
<!-- END revisions_button_icon.html -->
__template/tt2/revisions_controls.html__
<!-- BEGIN revisions_controls.html -->
[% id = hub.revisions.cgi.revision_id -%]
[% top = hub.pages.current.revision_number - 1 -%]
[% IF id > 1 -%]
<a href="[% script_name %]?action=revisions&page_id=[% page_id %]&revision_id=[% id - 1 %]" accesskey="p" title="Previous Revision">
[% INCLUDE revisions_controls_previous_icon.html %]
</a>
|
[% END -%]
<a href="[% script_name %]?[% page_id %]" accesskey="c" title="Current Revision">
[% INCLUDE revisions_controls_current_icon.html %]
</a>
[% IF id < top -%]
|
<a href="[% script_name %]?action=revisions&page_id=[% page_id %]&revision_id=[% id + 1 %]" accesskey="n" title="Next Revision">
[% INCLUDE revisions_controls_next_icon.html %]
</a>
[% END -%]
<!-- END revisions_controls.html -->
__template/tt2/revisions_controls_current_icon.html__
<!-- BEGIN revisions_controls_current_icon.html -->
Current
<!-- END revisions_controls_current_icon.html -->
__template/tt2/revisions_controls_next_icon.html__
<!-- BEGIN revisions_controls_next_icon.html -->
Next
<!-- END revisions_controls_next_icon.html -->
__template/tt2/revisions_controls_previous_icon.html__
<!-- BEGIN revisions_controls_previous_icon.html -->
Previous
<!-- END revisions_controls_previous_icon.html -->
__template/tt2/revisions_content.html__
<!-- BEGIN revisions_content.html -->
[% screen_title = "$page_id <span style=\"font-size:smaller;color:red\">(Revision $revision_id)</span>" -%]
[% INCLUDE display_changed_by.html %]
<div class="wiki">
[% page_html -%]
</div>
<!-- END revisions_content.html -->
