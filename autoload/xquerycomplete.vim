" XQuery completion script
" Language: XQuery
" Maintainer:   David Lam <dlam@dlam.me>
" Last Change: 2011 June 2
"
" Notes:
"   Completes W3C XQuery 'fn' functions, types and keywords. 
"
"   Also completes all the MarkLogic functions I could find at...
"   http://developer.marklogic.com/pubs/4.1/apidocs/All.html
"
" Usage:
"   Generally, just start by typing it's namespace and then <CTRL-x><CTRL-o>
"
"        fn<CTRL-x><CTRL-o>
"           ->  list of functions in the 'fn' namespace
"
"        fn:doc<CTRL-x><CTRL-o>
"           ->  fn:doc(
"                fn:doc-available(
"                fn:document-uri(
"
"        xs<CTRL-x><CTRL-o>
"           ->  list of all xquery types
"
"        decl<CTRL-x><CTRL-o>
"           ->  declare
"                declare function
"                declare namespace
"                declare option
"                declare default
"
"
"   :h complete-functions
"   :h omnifunc
"   :h filetype-plugin-on

 
if exists("b:did_xqueryomnicomplete")
    "finish
    delfunction xquerycomplete#CompleteXQuery
endif
let b:did_xqueryomnicomplete = 1
 
function! xquerycomplete#CompleteXQuery(findstart, base) 

  if a:findstart
	" locate the start of the word
	let line = getline('.')
	let start = col('.') - 1
	let curline = line('.')
	let compl_begin = col('.') - 2
    
    " 5/29/2010   \|  joins two regex branches!         :h pattern
	while start >= 0 && line[start - 1] =~ '\k\|:\|\-\|&'
		let start -= 1
	endwhile
	let b:compl_context = getline('.')[0:compl_begin]

	return start
  else

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "                                                                    "
    "        START START START COMPLETION LISTS START START START        "
    "                                                                    "
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " http://developer.marklogic.com/pubs/4.1/apidocs/AdminLibrary.htm
"{{{let admin_api_functions =
    let admin_api_functions = [
        \ 'appserver-add-namespace',
        \ 'appserver-add-request-blackout',
        \ 'appserver-add-schema',
        \ 'appserver-copy',
        \ 'appserver-delete',
        \ 'appserver-delete-namespace',
        \ 'appserver-delete-request-blackout',
        \ 'appserver-delete-schema',
        \ 'appserver-get-address',
        \ 'appserver-get-authentication',
        \ 'appserver-get-backlog',
        \ 'appserver-get-collation',
        \ 'appserver-get-compute-content-length',
        \ 'appserver-get-concurrent-request-limit',
        \ 'appserver-get-database',
        \ 'appserver-get-debug-allow',
        \ 'appserver-get-default-time-limit',
        \ 'appserver-get-default-user',
        \ 'appserver-get-default-xquery-version',
        \ 'appserver-get-display-last-login',
        \ 'appserver-get-enabled',
        \ 'appserver-get-error-handler',
        \ 'appserver-get-group-id',
        \ 'appserver-get-host-ids',
        \ 'appserver-get-id',
        \ 'appserver-get-keep-alive-timeout',
        \ 'appserver-get-last-login',
        \ 'appserver-get-log-errors',
        \ 'appserver-get-max-time-limit',
        \ 'appserver-get-modules-database',
        \ 'appserver-get-name',
        \ 'appserver-get-namespaces',
        \ 'appserver-get-output-encoding',
        \ 'appserver-get-output-sgml-character-entities',
        \ 'appserver-get-port',
        \ 'appserver-get-pre-commit-trigger-depth', 
        \ 'appserver-get-pre-commit-trigger-limit',
        \ 'appserver-get-privilege',
        \ 'appserver-get-profile-allow',
        \ 'appserver-get-request-blackouts',
        \ 'appserver-get-request-timeout',
        \ 'appserver-get-root',
        \ 'appserver-get-schemas',
        \ 'appserver-get-session-timeout',
        \ 'appserver-get-ssl-allow-sslv3',
        \ 'appserver-get-ssl-allow-tls',
        \ 'appserver-get-ssl-certificate-authorities',
        \ 'appserver-get-ssl-hostname',
        \ 'appserver-get-ssl-require-client-certificate',
        \ 'appserver-get-static-expires',
        \ 'appserver-get-threads',
        \ 'appserver-get-type',
        \ 'appserver-get-url-rewriter',
        \ 'appserver-one-time-request-blackout',
        \ 'appserver-recurring-request-blackout',
        \ 'appserver-set-address',
        \ 'appserver-set-authentication',
        \ 'appserver-set-backlog',
        \ 'appserver-set-collation',
        \ 'appserver-set-compute-content-length',
        \ 'appserver-set-concurrent-request-limit',
        \ 'appserver-set-database',
        \ 'appserver-set-debug-allow',
        \ 'appserver-set-time-limit',
        \ 'appserver-set-default-user',
        \ 'appserver-set-default-xquery-version',
        \ 'appserver-set-display-last-login',
        \ 'appserver-set-enabled',
        \ 'appserver-set-error-handler',
        \ 'appserver-set-keep-alive-timeout',
        \ 'appserver-set-last-login',
        \ 'appserver-set-log-errors',
        \ 'appserver-set-max-time-limit',
        \ 'appserver-set-modules-database',
        \ 'appserver-set-name',
        \ 'appserver-set-output-encoding',
        \ 'appserver-set-output-sgml-character-entities',
        \ 'appserver-set-port',
        \ 'appserver-set-pre-commit-trigger-depth',
        \ 'appserver-set-pre-commit-trigger-limit',
        \ 'appserver-set-privilege',
        \ 'appserver-set-profile-allow',
        \ 'appserver-set-request-timeout',
        \ 'appserver-set-root',
        \ 'appserver-set-session-timeout',
        \ 'appserver-set-ssl-allow-sslv3',
        \ 'appserver-set-ssl-allow-tls',
        \ 'appserver-set-ssl-certificate-template',
        \ 'appserver-set-ssl-ciphers',
        \ 'appserver-set-ssl-client-certificate-authorities',
        \ 'appserver-set-ssl-hostname',
        \ 'appserver-set-ssl-require-client-certificate',
        \ 'appserver-set-static-expires',
        \ 'appserver-set-threads',
        \ 'appserver-set-url-rewriter',
        \ 'database-add-backup',
        \ 'database-add-element-attribute-word-lexicon',
        \ 'database-add-element-word-lexicon',
        \ 'database-add-element-word-query-through',
        \ 'database-add-field',
        \ 'database-add-field-excluded-element',
        \ 'database-add-field-included-element',
        \ 'database-add-field-word-lexicon',
        \ 'database-add-fragment-parent',
        \ 'database-add-fragment-root',
        \ 'database-add-geospatial-element-attribute-pair-index',
        \ 'database-add-geospatial-element-child-index',
        \ 'database-add-geospatial-element-index',
        \ 'database-add-merge-blackout',
        \ 'database-add-phrase-around',
        \ 'database-add-phrase-through',
        \ 'database-add-range-element-attribute-index',
        \ 'database-add-range-element-index',
        \ 'database-add-word-lexicon',
        \ 'database-add-word-query-excluded-element',
        \ 'database-add-word-query-included-element',
        \ 'database-attach-forest',
        \ 'database-copy',
        \ 'database-create',
        \ 'database-daily-backup',
        \ 'database-delete',
        \ 'database-delete-backup',
        \ 'database-delete-element-attribute-word-lexicon',
        \ 'database-delete-element-word-lexicon',
        \ 'database-delete-element-word-query-through',
        \ 'database-delete-field',
        \ 'database-delete-field-excluded-element',
        \ 'database-delete-field-included-element',
        \ 'database-delete-field-word-lexicon',
        \ 'database-delete-fragment-parent',
        \ 'database-delete-fragment-root',
        \ 'database-delete-geospatial-element-attribute-pair-index',
        \ 'database-delete-geospatial-element-child-index',
        \ 'database-delete-geospatial-element-index',
        \ 'database-delete-geospatial-element-pair-index',
        \ 'database-delete-merge-blackout',
        \ 'database-delete-phrase-around',
        \ 'database-delete-range-element-attribute-index',
        \ 'database-delete-range-element-index',
        \ 'database-delete-word-lexicon',
        \ 'database-delete-word-query-excluded-element',
        \ 'database-delete-word-query-included-element',
        \ 'database-detach-forest',
        \ 'database-element-attribute-word-lexicon',
        \ 'database-element-word-lexicon',
        \ 'database-eleemnt-word-query-through',
        \ 'database-excluded-element',
        \ 'database-field',
        \ 'database-fragment-parent',
        \ 'database-fragment-root',
        \ 'database-geospatial-element-attribute-pair-index',
        \ 'database-geospatial-element-child-index',
        \ 'database-geospatial-element-index',
        \ 'database-geospatial-element-pair-index',
        \ 'database-get-attached-forests',
        \ 'database-get-attribute-value-positions',
        \ 'database-get-backups',
        \ 'database-get-collection-lexicon',
        \ 'database-get-directory-creation',
        \ 'database-get-element-attribute-word-lexicons',
        \ 'database-get-element-value-positions',
        \ 'database-get-element-word-lexicons',
        \ 'database-get-element-word-positions',
        \ 'database-get-element-word-query-throughs',
        \ 'database-get-enabled',
        \ 'database-get-expunge-locks',
        \ 'database-get-fast-case-sensitive-searches',
        \ 'database-get-fast-diacritic-sensitive-searches',
        \ 'database-get-fast-element-character-searches',
        \ 'database-get-fast-element-phrase-searches',
        \ 'database-get-fast-element-trailing-wildcard-searches',
        \ 'database-get-fast-element-word-searches',
        \ 'database-get-fast-phrase-searches',
        \ 'database-get-fast-reverse-searches',
        \ 'database-get-field']
    " end of xdmp_appserver_functions on 78
    
        " and more TODO...
"}}}

    
    " http://developer.marklogic.com/pubs/4.1/apidocs/alerting.html
    " let alertfunctions = ["{{{
    let alertfunctions = [
        \ 'action-get-description',
        \ 'action-get-module',
        \ 'action-get-module-db',
        \ 'action-get-module-root',
        \ 'action-get-name',
        \ 'action-get-options',
        \ 'action-insert',
        \ 'action-remove',
        \ 'action-set-description',
        \ 'action-set-module',
        \ 'action-set-module-db',
        \ 'action-set-module-root',
        \ 'action-set-name',
        \ 'action-set-options',
        \ 'config-delete',
        \ 'config-get',
        \ 'config-get-cpf-domain-ids',
        \ 'config-get-cpf-domain-names',
        \ 'config-get-description',
        \ 'config-get-id',
        \ 'config-get-name',
        \ 'config-get-options',
        \ 'config-get-trigger-ids',
        \ 'config-get-uri',
        \ 'config-insert',
        \ 'config-set-cpf-domain-ids',
        \ 'config-set-cpf-domain-names',
        \ 'config-set-description',
        \ 'config-set-name',
        \ 'config-set-options',
        \ 'config-set-trigger-ids',
        \ 'create-triggers',
        \ 'find-matching-rules',
        \ 'get-actions',
        \ 'get-all-rules',
        \ 'get-my-rules',
        \ 'invoke-matching-actions',
        \ 'make-action',
        \ 'make-config',
        \ 'make-log-action',
        \ 'make-rule',
        \ 'remove-triggers',
        \ 'rule-action-query',
        \ 'rule-get-action',
        \ 'rule-get-id',
        \ 'rule-get-name',
        \ 'rule-get-options',
        \ 'rule-get-query',
        \ 'rule-get-user-id',
        \ 'rule-id-query',
        \ 'rule-insert',
        \ 'rule-name-query',
        \ 'rule-remove',
        \ 'rule-set-action',
        \ 'rule-set-description',
        \ 'rule-set-name',
        \ 'rule-set-options',
        \ 'rule-set-query',
        \ 'rule-set-user-id',
        \ 'rule-user-id-query',
        \ 'spawn-matching-actions']
    " end of alert: functions on line 71!
"}}}


    " http://developer.marklogic.com/pubs/4.1/apidocs/Classifier.html
    let cts_classifier_functions = ['classify', 'thresholds', 'train']

    " cts:
    " http://developer.marklogic.com/pubs/4.1/apidocs/cts-query.html
    " let cts_query_constructor_functions = [ "{{{
    let cts_query_constructor_functions = [ 
        \ 'and-not-query',
        \ 'and-query',
        \ 'collection-query',
        \ 'directory-query',
        \ 'document-query',
        \ 'element-attribute-pair-geospatial-query',
        \ 'element-attribute-range-query',
        \ 'element-attribute-value-query',
        \ 'element-attribute-word-query',
        \ 'element-child-geospatial-query',
        \ 'element-geospatial-query',
        \ 'element-pair-geospatial-query',
        \ 'element-query',
        \ 'element-range-query',
        \ 'element-value-query',
        \ 'element-word-query',
        \ 'field-word-query',
        \ 'near-query',
        \ 'not-query',
        \ 'or-query',
        \ 'properties-query',
        \ 'query',
        \ 'registered-query',
        \ 'reverse-query',
        \ 'similar-query',
        \ 'word-query']
    " end of cts query constructors on 142
"}}}
    

    " cts:
    " http://developer.marklogic.com/pubs/4.1/apidocs/GeospatialBuiltins.html
    " let ctsgeospatial_functions = ["{{{
    let ctsgeospatial_functions = [
        \ 'arc-intersection',
        \ 'bearing',
        \ 'box',
        \ 'box-east',
        \ 'box-north',
        \ 'box-south',
        \ 'box-west',
        \ 'circle',
        \ 'circle-center',
        \ 'circle-radius',
        \ 'destination',
        \ 'distance',
        \ 'point',
        \ 'point-latitude',
        \ 'point-longitude',
        \ 'polygon',
        \ 'polygon-vertices',
        \ 'shortest-distance']
"}}}


    " cts:
    " http://developer.marklogic.com/pubs/4.1/apidocs/GeospatialLexicons.html
    " let ctsgeospatial_lexicons_functions = ["{{{
    let ctsgeospatial_lexicons_functions = [
        \ 'element-attribute-pair-geospatial-boxes',
        \ 'element-attribute-pair-geospatial-value-match',
        \ 'element-attribute-pair-geospatial-values',
        \ 'element-attribute-value-geospatial-co-occurrences',
        \ 'element-child-geospatial-boxes',
        \ 'element-child-geospatial-value-match',
        \ 'element-child-geospatial-values',
        \ 'element-pair-geospatial-boxes',
        \ 'element-pair-geospatial-value-match',
        \ 'element-pair-geospatial-values',
        \ 'element-value-geospatial-co-occurrences',
        \ 'geospatial-co-occurrences']
"}}}

    " cts:
    " http://developer.marklogic.com/pubs/4.1/apidocs/Lexicons.html
    " let cts_lexicon_functions = ["{{{
    let cts_lexicon_functions = [
        \ 'collection-match',
        \ 'collections',
        \ 'element-attribute-value-co-occurrences',
        \ 'element-attribute-value-match',
        \ 'element-attribute-value-ranges',
        \ 'element-attribute-values',
        \ 'element-attribute-word-match',
        \ 'element-attribute-words',
        \ 'element-value-co-occurrences',
        \ 'element-value-match',
        \ 'element-value-ranges',
        \ 'element-values',
        \ 'element-word-match',
        \ 'element-words',
        \ 'field-word-match',
        \ 'field-words',
        \ 'frequency',
        \ 'uri-match',
        \ 'uris',
        \ 'word-match',
        \ 'words']
"}}}

    " cts:
    " http://developer.marklogic.com/pubs/4.1/apidocs/SearchBuiltins.html
    " let cts_search_functions = ["{{{
    let cts_search_functions = [
        \ 'confidence',
        \ 'contains',
        \ 'deregister',
        \ 'entity-highlight',
        \ 'fitness',
        \ 'highlight',
        \ 'quality',
        \ 'register',
        \ 'remainder',
        \ 'score',
        \ 'search',
        \ 'stem',
        \ 'tokenize',
        \ 'walk']
"}}}
        
    let all_ctsfunctions = 
        \ cts_classifier_functions +
        \ cts_query_constructor_functions +
        \ cts_lexicon_functions +
        \ cts_search_functions

    " search:
    " http://developer.marklogic.com/pubs/4.1/apidocs/SearchAPI.html
    " let search_api_functions = ["{{{
    let search_api_functions = [
        \ 'check-options',
        \ 'estimate',
        \ 'get-default-options',
        \ 'parse',
        \ 'remove-constraint',
        \ 'resolve',
        \ 'resolve-nodes', 
        \ 'search', 
        \ 'snippet', 
        \ 'suggest', 
        \ 'unparse']
"}}}

    " admin:
    " http://developer.marklogic.com/pubs/4.1/apidocs/AdminBuiltins.html
    " let xdmp_admin_functions = ["{{{
    let xdmp_admin_functions = [
        \ 'database-backup', 
        \ 'database-backup-cancel', 
        \ 'database-backup-purge', 
        \ 'database-backup-validate', 
        \ 'database-restore',
        \ 'database-restore-cancel', 
        \ 'database-restore-status', 
        \ 'database-restore-validate', 
        \ 'filesystem-directory', 
        \ 'filesystem-file',
        \ 'forest-backup', 
        \ 'forest-clear', 
        \ 'forest-restart', 
        \ 'forest-restore', 
        \ 'merge-cancel', 
        \ 'restart', 
        \ 'shutdown']
"}}}

    " let xdmp_appserver_functions = ["{{{
    let xdmp_appserver_functions = [
        \ 'get-request-url',
        \ 'add-response-header',
        \ 'get-request-body',
        \ 'get-request-client-address',
        \ 'get-request-client-certificate',
        \ 'get-request-field-content-type',
        \ 'get-request-field-filename',
        \ 'get-request-field-names',
        \ 'get-request-header',
        \ 'get-request-header-names',
        \ 'get-request-method',
        \ 'get-request-path',
        \ 'get-request-protocol',
        \ 'get-request-username',
        \ 'get-response-code',
        \ 'get-response-encoding',
        \ 'get-session-field',
        \ 'get-session-field-names',
        \ 'login',
        \ 'logout',
        \ 'set-request-time-limit',
        \ 'set-response-code',
        \ 'set-response-content-type',
        \ 'set-response-encoding',
        \ 'set-session-field',
        \ 'uri-is-file',
        \ 'url-decode',
        \ 'url-encode',
        \ 'x509-certificate-extract']
    " end of xdmp_appserver_functions on 110
"}}}

    " xdmp:
    " http://developer.marklogic.com/pubs/4.1/apidocs/Document-Conversion.html
    " let xdmp_document_conversion_functions = ["{{{
    let xdmp_document_conversion_functions = [
        \ 'excel-convert', 
        \ 'pdf-convert', 
        \ 'powerpoint-convert', 
        \ 'tidy', 
        \ 'word-convert',
        \ 'zip-create',
        \ 'zip-get',
        \ 'zip-manifest']
"}}}

    " http://developer.marklogic.com/pubs/4.1/apidocs/Extension.html
    " let xdmp_extension_functions = ["{{{
    let xdmp_extension_functions = [
        \ 'directory', 
        \ 'estimate', 
        \ 'node-uri', 
        \ 'invoke', 
        \ 'log', 
        \ 'set', 
        \ 'value', 
        \ 'document-get-collections', 
        \ 'document-get-properties', 
        \ 'access',
        \ 'add64', 
        \ 'apply', 
        \ 'architecture', 
        \ 'base64-decode', 
        \ 'base64-encode', 
        \ 'castable-as', 
        \ 'collation-canonical-uri', 
        \ 'collection-locks',
        \ 'collection-properties', 
        \ 'database', 
        \ 'database-forests', 
        \ 'database-name', 
        \ 'databases',
        \ 'describe', 
        \ 'diacritic-less', 
        \ 'directory-locks', 
        \ 'directory-properties', 
        \ 'document-forest', 
        \ 'document-get', 
        \ 'document-get-quality', 
        \ 'document-locks', 
        \ 'document-properties', 
        \ 'elapsed-time', 
        \ 'element-content-type', 
        \ 'email', 
        \ 'eval',
        \ 'eval-in', 
        \ 'exists', 
        \ 'forest', 
        \ 'forest-databases', 
        \ 'forest-name', 
        \ 'forests', 
        \ 'from-json', 
        \ 'function', 
        \ 'function-module', 
        \ 'function-name',
        \ 'get', 
        \ 'group', 
        \ 'group-hosts', 
        \ 'group-name', 
        \ 'group-servers', 
        \ 'groups',
        \ 'hash32', 
        \ 'hash64', 
        \ 'hex-to-integer', 
        \ 'host', 
        \ 'host-name', 
        \ 'hosts',
        \ 'http-delete', 
        \ 'http-get', 
        \ 'http-head', 
        \ 'http-options', 
        \ 'http-post',
        \ 'http-put', 
        \ 'integer-to-hex', 
        \ 'integer-to-octal', 
        \ 'invoke-in',
        \ 'log-level', 
        \ 'md5', 
        \ 'modules-database', 
        \ 'modules-root', 
        \ 'mul64',
        \ 'node-database', 
        \ 'node-kind', 
        \ 'octal-to-integer', 
        \ 'path', 
        \ 'platform',
        \ 'pretty-print', 
        \ 'product-edition', 
        \ 'query-meters', 
        \ 'query-trace', 
        \ 'quote',
        \ 'random', 
        \ 'request', 
        \ 'request-timestamp', 
        \ 'rethrow', 
        \ 'schema-database',
        \ 'security-database', 
        \ 'server', 
        \ 'server-name', 
        \ 'servers', 
        \ 'sleep',
        \ 'spawn', 
        \ 'spawn-in', 
        \ 'strftime', 
        \ 'subbinary', 
        \ 'to-json', 
        \ 'trace',
        \ 'triggers-database', 
        \ 'unpath', 
        \ 'unquote', 
        \ 'uri-content-type', 
        \ 'uri-format', 
        \ 'user-last-login', 
        \ 'version', 
        \ 'with-namespaces', 
        \ 'xquery-version']
    " end of xdmp_extension_functions on 110
"}}}
    
    " http://developer.marklogic.com/pubs/4.1/apidocs/Security.html
    " let xdmp_security_functions = ["{{{
    let xdmp_security_functions = [
        \ 'document-get-permissions',
        \ 'get-current-user',
        \ 'get-current-roles',
        \ 'security-assert',
        \ 'amp',
        \ 'amp-roles',
        \ 'can-grant-roles',
        \ 'default-collections',
        \ 'default-permissions',
        \ 'has-privilege',
        \ 'permission',
        \ 'privilege',
        \ 'privilege-roles',
        \ 'role',
        \ 'role-roles',
        \ 'user',
        \ 'user-roles']
    " end of xdmp_security_functions on 252
"}}}
   
    " http://developer.marklogic.com/pubs/4.1/apidocs/ServerMonitoring.html
    " let xdmp_server_monitoring_functions = ["{{{
    let xdmp_server_monitoring_functions = [
        \ 'forest-counts',
        \ 'forest-status',
        \ 'host-status',
        \ 'request-cancel',
        \ 'request-status',
        \ 'server-status']
"}}}

    " http://developer.marklogic.com/pubs/4.1/apidocs/UpdateBuiltins.html
    " let xdmp_update_functions = ["{{{
    let xdmp_update_functions = [
        \ 'document-delete',
        \ 'document-load',
        \ 'document-set-collections', 
        \ 'document-add-collection',
        \ 'document-set-permissions',
        \ 'document-add-permissions',
        \ 'document-remove-permissions',
        \ 'document-set-properties',
        \ 'document-add-properties',
        \ 'document-remove-properties',
        \ 'node-delete',
        \ 'collection-delete', 
        \ 'directory-create',
        \ 'directory-delete',
        \ 'document-set-property', 
        \ 'document-set-quality',
        \ 'load', 
        \ 'lock-acquire',
        \ 'lock-release',
        \ 'merge',
        \ 'merging',
        \ 'node-insert-after',
        \ 'node-insert-before',
        \ 'save']
    "}}}

    let COMMON_xdmp_functions = [
        \ 'get-request-field', 
        \ 'document-insert',
        \ 'node-replace',
        \ 'node-insert-child',
        \ 'node-delete',
        \ 'redirect-response']

    let all_xdmp_functions = 
        \ COMMON_xdmp_functions +
        \ xdmp_extension_functions +
        \ xdmp_update_functions +
        \ xdmp_security_functions  +
        \ xdmp_admin_functions + 
        \ xdmp_appserver_functions + 
        \ xdmp_document_conversion_functions +
        \ xdmp_server_monitoring_functions 

    " http://developer.marklogic.com/pubs/4.1/apidocs/W3C.html
    " let fnfunctions = ["{{{
    let fnfunctions = [
        \ 'doc',
        \ 'concat', 
        \ 'count', 
        \ 'empty', 
        \ 'exists', 
        \ 'abs', 
        \ 'adjust-date-to-timezone', 
        \ 'adjust-dateTime-to-timezone', 
        \ 'avg', 
        \ 'base-uri', 
        \ 'boolean',
        \ 'ceiling', 
        \ 'codepoint-equal', 
        \ 'codepoints-to-string', 
        \ 'collection',
        \ 'compare', 
        \ 'contains', 
        \ 'current-date',
        \ 'current-dateTime', 
        \ 'current-time', 
        \ 'data', 
        \ 'day-from-date',
        \ 'day-from-dateTime', 
        \ 'days-from-duration', 
        \ 'deep-equal',
        \ 'default-collation', 
        \ 'distinct-nodes', 
        \ 'distinct-values', 
        \ 'doc-available', 
        \ 'document-uri', 
        \ 'encode-for-uri',
        \ 'ends-with', 
        \ 'error', 
        \ 'escape-html-uri', 
        \ 'escape-uri', 
        \ 'exactly-one',
        \ 'expanded-QName', 
        \ 'false', 
        \ 'floor', 
        \ 'hours-from-dateTime',
        \ 'hours-from-duration', 
        \ 'hours-from-time', 
        \ 'id', 
        \ 'idref',
        \ 'implicit-timezone', 
        \ 'in-scope-prefixes', 
        \ 'index-of', 
        \ 'insert-before',
        \ 'iri-to-uri', 
        \ 'lang', 
        \ 'last', 
        \ 'local-name', 
        \ 'local-name-from-QName', 
        \ 'lower-case', 
        \ 'matches', 
        \ 'max', 
        \ 'min', 
        \ 'minutes-from-dateTime', 
        \ 'minutes-from-duration', 
        \ 'minutes-from-time', 
        \ 'month-from-date', 
        \ 'month-from-dateTime', 
        \ 'months-from-duration', 
        \ 'name', 
        \ 'namespace-uri',
        \ 'namespace-uri-for-prefix', 
        \ 'namespace-uri-from-QName', 
        \ 'nilled', 
        \ 'node-kind', 
        \ 'node-name', 
        \ 'normalize-space', 
        \ 'normalize-unicode',
        \ 'not', 
        \ 'number', 
        \ 'one-or-more', 
        \ 'position', 
        \ 'prefix-from-QName', 
        \ 'QName', 
        \ 'remove', 
        \ 'replace', 
        \ 'resolve-QName', 
        \ 'resolve-uri', 
        \ 'reverse', 
        \ 'root', 
        \ 'round', 
        \ 'round-half-to-even', 
        \ 'seconds-from-dateTime',
        \ 'seconds-from-duration', 
        \ 'seconds-from-time', 
        \ 'starts-with',
        \ 'static-base-uri', 
        \ 'string', 
        \ 'string-join', 
        \ 'string-length', 
        \ 'string-pad', 
        \ 'string-to-codepoints', 
        \ 'subsequence', 
        \ 'substring', 
        \ 'substring-after', 
        \ 'substring-before', 
        \ 'sum', 
        \ 'tokenize', 
        \ 'trace',
        \ 'translate', 
        \ 'true', 
        \ 'unordered', 
        \ 'upper-case', 
        \ 'year-from-date', 
        \ 'year-from-dateTime', 
        \ 'years-from-duration', 
        \ 'zero-or-one']
    " end of fn_functions on 226
"}}}


    " 8/6/2010  Putting variable types here 

    "
    "  see Walmsley:490  in index!
    "  atomicType chart?   Walmsley:144
    "  generic sequence types?  Walmsley:152
    "
    "    wat about.... 
    "       comment()
    "       processing-instruction()
    "       document-node()
    "
    " let generic_types = ["{{{
    let generic_types = [
        \ 'item()', 
        \ 'node()',
        \ 'text()',
        \ 'empty-sequence()',
        \ 'element()', 
        \ 'document()'
        \ ]"}}}
    

    " these are prefixed with xs:  
    " let atomic_types = ["{{{
    let atomic_types = [
        \ 'xs:string',
        \ 'xs:dateTime',
        \ 'xs:anyAtomicType',
        \ 'xs:anyType',
        \ 'xs:anyURI',
        \ 'xs:base64Binary',
        \ 'xs:boolean',
        \ 'xs:date',
        \ 'xs:dayTimeDuration',
        \ 'xs:decimal',
        \ 'xs:double',
        \ 'xs:duration',
        \ 'xs:float',
        \ 'xs:gDay',
        \ 'xs:gMonth',
        \ 'xs:gMonthDay',
        \ 'xs:gYearMonth',
        \ 'xs:gYear',
        \ 'xs:hexBinary',
        \ 'xs:integer',
        \ 'xs:negativeInteger',
        \ 'xs:nonPositiveInteger',
        \ 'xs:nonNegativeInteger',
        \ 'xs:normalizedString',
        \ 'xs:positiveInteger',
        \ 'xs:time',
        \ 'xs:QName',
        \ 'xs:unsignedByte',
        \ 'xs:unsignedInt',
        \ 'xs:unsignedLong',
        \ 'xs:unsignedShort',
        \ 'xs:yearMonthDuration'
        \ ]"}}}
    

    let all_types = generic_types + atomic_types


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "                                                                                "
    "             END END END END COMPLETION LISTS END END END END                   "
    "                                                                                "
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " 8/3/2010  leaving out XInclude stuff intentionally...

    " TODO add option to include geospatial completions!
    let geospatial_namespaces       = ["geo", "georss", "gml", "kml", "mcgm"]

    let library_modules_namespaces  = ["admin", "alert", "dls", "entity", "pki", "search", "sec", "spell", "thsr", "trgr", "ooxml"]
    let cpf_function_namespaces     = ["cpf", "css", "dbk", "dom", "cvt", "lnk", "msword", "pdf", "p", "ppt", "xhtml"]
    let builtin_function_namespaces = ["cts", "dbg", "fn", "map", "math", "prof",  "xdmp"]

    " From spec: 'Certain namespace prefixes are predeclared by XQuery and
    " bound to fixed namespace URIs. These namespace prefixes are as follows:'
    let predeclared_namespaces = ['fn', 'xs', 'local', 'xsi', 'xml']

    let ALL_FUNCTION_NAMESPACES = 
        \ library_modules_namespaces +
        \ cpf_function_namespaces +
        \ builtin_function_namespaces +
        \ predeclared_namespaces

    "  When completing a namespace, the user will almost 
    "  always want the colon after it too!
    "
    "   --> see javascriptcomplete.vim:583
	call map(ALL_FUNCTION_NAMESPACES, 'v:val.":"')

    let namespace            = a:base
    let function_completions = []
    let final_menu           = []

    if namespace =~ 'xdmp'
      call map(all_xdmp_functions, '"xdmp:" . v:val . "("')
      let function_completions = copy(all_xdmp_functions)
    elseif namespace =~ 'cts'
      call map(all_ctsfunctions, '"cts:" . v:val . "("')
      let function_completions = copy(all_ctsfunctions)
    elseif namespace =~ 'fn'
      call map(fnfunctions, '"fn:" . v:val . "("')
      let function_completions = copy(fnfunctions)
    elseif namespace =~ 'search'
      call map(search_api_functions, '"search:" . v:val . "("')
      let function_completions = copy(search_api_functions)
    elseif namespace =~ 'admin'
      call map(admin_api_functions, '"admin:" . v:val . "("')
      let function_completions = copy(admin_api_functions)
    elseif namespace =~ 'alert'
      call map(alertfunctions, '"alert:" . v:val . "("')
      let function_completions = copy(alertfunctions)
    elseif namespace =~ 'xs'
      let function_completions = atomic_types
    endif



    " see Walmsley p. 27 'Categories of Expressions'

    "let keywords = ["{{{
    let keywords = [
        \ "for", 
        \ "let", 
        \ "where", 
        \ "order by", 
        \ "return", 
        \ "some", 
        \ "every", 
        \ "in", 
        \ "satisfies", 
        \ "to", 
        \ "union", 
        \ "intersect", 
        \ "except", 
        \ "instance of", 
        \ "typeswitch", 
        \ "cast as", 
        \ "castable as", 
        \ "treat", 
        \ 'variable',
        \ "validate", 
        \ "div", 
        \ "idiv", 
        \ "mod", 
        \ "xquery version \"1.0-ml\";",
        \ "xquery version \"0.9-ml\";",
        \ "xquery version \"1.0\";",
        \ "xquery version"
        \ ]
"}}}
    
    "  hmmm above ^^ dont have everything 
    "
    " let morekeywords = ["{{{
    let morekeywords = [
        \ 'as',
        \ 'declare',
        \ 'declare function',
        \ 'declare variable',
        \ 'declare namespace',
        \ 'declare option',
        \ 'declare default',
        \ 'default',
        \ 'option',
        \ 'collation',
        \ 'element',
        \ 'attribute',
        \ 'function',
        \ 'import',
        \ 'import module',
        \ 'import module namespace',
        \ 'import schema',
        \ 'module',
        \ 'namespace',
        \ 'module namespace',
        \ 'external;',
        \ 'encoding;',
        \ 'ascending',
        \ 'descending',
        \ ]
"}}}

    " let evenmorekeywords = ["{{{
    let evenmorekeywords = [
        \ 'else',
        \ 'else if',
        \ 'then',
        \ 'if'
        \ ]
"}}}

    "  let predefined_entity_references = ["{{{
    "  http://www.w3.org/TR/xquery/#dt-predefined-entity-reference
    let predefined_entity_references = [
        \ '&amp;',
        \ '&lt;',
        \ '&gt;',
        \ '&quot;',
        \ '&apos;'
        \ ]
"}}}


    if(a:base =~ '&$')
        "...the character right before the cursor is an ampersand"
        return predefined_entity_references
    else 

        let res  = []
        let res2 = []
        let values = evenmorekeywords + keywords + morekeywords + function_completions + ALL_FUNCTION_NAMESPACES + generic_types + predefined_entity_references

        for v in values
            if v =~? '^'.a:base
                call add(res, v)
            elseif v =~? a:base
                call add(res2, v)
            endif
        endfor

        let final_menu = res + res2
        return final_menu
    endif
  endif
endfunction 


" vim:sw=4 fdm=marker tw=80
