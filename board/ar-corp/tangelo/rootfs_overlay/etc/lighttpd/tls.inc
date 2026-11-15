# Printed by etc/lighttpd/tls.sh only when the key and certificate are readable.
server.modules += ( "mod_gnutls" )
$SERVER["socket"] == "0.0.0.0:443" {
	ssl.engine  = "enable"
	ssl.pemfile = "/var/lib/lighttpd/tls/cert.pem"
	ssl.privkey = "/var/lib/lighttpd/tls/key.pem"
	# GnuTLS SECURE:%PROFILE_MEDIUM (lighttpd's default), TLS 1.2 and up.
	ssl.openssl.ssl-conf-cmd = ( "MinProtocol" => "TLSv1.2" )
}
