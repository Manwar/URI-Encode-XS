use strict;
package URI::Encode::XS;

use XSLoader;
use Exporter 5.57 'import';

our $VERSION     = '0.01';
our @EXPORT_OK   = ( qw/uri_encode uri_decode/ );

XSLoader::load('URI::Encode::XS', $VERSION);

1;
