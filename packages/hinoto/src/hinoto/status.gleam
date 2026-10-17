/// HTTP Status Codes
///
/// This module provides constants for all standard HTTP status codes
/// as defined in RFC 7231 and related specifications.
///
/// Status codes are grouped by their first digit:
/// - 1xx: Informational responses
/// - 2xx: Success responses
/// - 3xx: Redirection responses
/// - 4xx: Client error responses
/// - 5xx: Server error responses
/// 1xx Informational Response Status Codes
///
/// These status codes indicate that the request was received and understood,
/// and that the client should continue with the request or ignore if already finished.
/// 100 Continue - The server has received the request headers and the client should proceed to send the request body.
pub const continue = 100

/// 101 Switching Protocols - The requester has asked the server to switch protocols.
pub const switching_protocols = 101

/// 102 Processing - The server has received and is processing the request, but no response is available yet.
pub const processing = 102

/// 103 Early Hints - Used to return some response headers before final HTTP message.
pub const early_hints = 103

/// 2xx Success Status Codes
///
/// These status codes indicate that the client's request was successfully
/// received, understood, and accepted.
/// 200 OK - The request has succeeded.
pub const ok = 200

/// 201 Created - The request has been fulfilled and resulted in a new resource being created.
pub const created = 201

/// 202 Accepted - The request has been accepted for processing, but processing is not complete.
pub const accepted = 202

/// 203 Non-Authoritative Information - The request was successful but the enclosed payload has been modified.
pub const non_authoritative_information = 203

/// 204 No Content - The request was successful but there is no content to send back.
pub const no_content = 204

/// 205 Reset Content - The request was successful and the user agent should reset the document view.
pub const reset_content = 205

/// 206 Partial Content - The server is delivering only part of the resource due to a range header.
pub const partial_content = 206

/// 207 Multi-Status - Conveys information about multiple resources in situations where multiple status codes might be appropriate.
pub const multi_status = 207

/// 208 Already Reported - Used inside a DAV: propstat response element to avoid enumerating the internal members of multiple bindings.
pub const already_reported = 208

/// 226 IM Used - The server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations.
pub const im_used = 226

/// 3xx Redirection Status Codes
///
/// These status codes indicate that further action needs to be taken
/// by the user agent in order to fulfill the request.
/// 300 Multiple Choices - The request has more than one possible response.
pub const multiple_choices = 300

/// 301 Moved Permanently - The URL of the requested resource has been changed permanently.
pub const moved_permanently = 301

/// 302 Found - The URI of requested resource has been changed temporarily.
pub const found = 302

/// 303 See Other - The server sent this response to direct the client to get the requested resource at another URI with a GET request.
pub const see_other = 303

/// 304 Not Modified - This is used for caching purposes. It tells the client that the response has not been modified.
pub const not_modified = 304

/// 305 Use Proxy - Defined in a previous version of the HTTP specification to indicate that a requested response must be accessed by a proxy.
pub const use_proxy = 305

/// 307 Temporary Redirect - The server sends this response to direct the client to get the requested resource at another URI with same method that was used in the prior request.
pub const temporary_redirect = 307

/// 308 Permanent Redirect - This means that the resource is now permanently located at another URI, specified by the Location: HTTP Response header.
pub const permanent_redirect = 308

/// 4xx Client Error Status Codes
///
/// These status codes indicate that the client seems to have made an error.
/// The client should not repeat the request without modification.
/// 400 Bad Request - The server could not understand the request due to invalid syntax.
pub const bad_request = 400

/// 401 Unauthorized - Although the HTTP standard specifies "unauthorized", semantically this response means "unauthenticated".
pub const unauthorized = 401

/// 402 Payment Required - This response code is reserved for future use.
pub const payment_required = 402

/// 403 Forbidden - The client does not have access rights to the content.
pub const forbidden = 403

/// 404 Not Found - The server can not find the requested resource.
pub const not_found = 404

/// 405 Method Not Allowed - The request method is known by the server but is not supported by the target resource.
pub const method_not_allowed = 405

/// 406 Not Acceptable - This response is sent when the web server, after performing server-driven content negotiation, doesn't find any content that conforms to the criteria given by the user agent.
pub const not_acceptable = 406

/// 407 Proxy Authentication Required - This is similar to 401 but authentication is needed to be done by a proxy.
pub const proxy_authentication_required = 407

/// 408 Request Timeout - This response is sent on an idle connection by some servers, even without any previous request by the client.
pub const request_timeout = 408

/// 409 Conflict - This response is sent when a request conflicts with the current state of the server.
pub const conflict = 409

/// 410 Gone - This response is sent when the requested content has been permanently deleted from server, with no forwarding address.
pub const gone = 410

/// 411 Length Required - Server rejected the request because the Content-Length header field is not defined and the server requires it.
pub const length_required = 411

/// 412 Precondition Failed - The client has indicated preconditions in its headers which the server does not meet.
pub const precondition_failed = 412

/// 413 Content Too Large - Request entity is larger than limits defined by server.
pub const content_too_large = 413

/// 414 URI Too Long - The URI requested by the client is longer than the server is willing to interpret.
pub const uri_too_long = 414

/// 415 Unsupported Media Type - The media format of the requested data is not supported by the server.
pub const unsupported_media_type = 415

/// 416 Range Not Satisfiable - The range specified by the Range header field in the request can't be fulfilled.
pub const range_not_satisfiable = 416

/// 417 Expectation Failed - This response code means the expectation indicated by the Expect request header field can't be met by the server.
pub const expectation_failed = 417

/// 421 Misdirected Request - The request was directed at a server that is not able to produce a response.
pub const misdirected_request = 421

/// 422 Unprocessable Content - The request was well-formed but was unable to be followed due to semantic errors.
pub const unprocessable_content = 422

/// 423 Locked - The resource that is being accessed is locked.
pub const locked = 423

/// 424 Failed Dependency - The request failed due to failure of a previous request.
pub const failed_dependency = 424

/// 425 Too Early - Indicates that the server is unwilling to risk processing a request that might be replayed.
pub const too_early = 425

/// 426 Upgrade Required - The server refuses to perform the request using the current protocol but might be willing to do so after the client upgrades to a different protocol.
pub const upgrade_required = 426

/// 428 Precondition Required - The origin server requires the request to be conditional.
pub const precondition_required = 428

/// 429 Too Many Requests - The user has sent too many requests in a given amount of time ("rate limiting").
pub const too_many_requests = 429

/// 431 Request Header Fields Too Large - The server is unwilling to process the request because its header fields are too large.
pub const request_header_fields_too_large = 431

/// 451 Unavailable For Legal Reasons - The user-agent requested a resource that cannot legally be provided.
pub const unavailable_for_legal_reasons = 451

/// 5xx Server Error Status Codes
///
/// These status codes indicate that the server failed to fulfill
/// an apparently valid request.
/// 500 Internal Server Error - The server has encountered a situation it doesn't know how to handle.
pub const internal_server_error = 500

/// 501 Not Implemented - The request method is not supported by the server and cannot be handled.
pub const not_implemented = 501

/// 502 Bad Gateway - This error response means that the server, while working as a gateway to get a response needed to handle the request, got an invalid response.
pub const bad_gateway = 502

/// 503 Service Unavailable - The server is not ready to handle the request.
pub const service_unavailable = 503

/// 504 Gateway Timeout - This error response is given when the server is acting as a gateway and cannot get a response in time.
pub const gateway_timeout = 504

/// 505 HTTP Version Not Supported - The HTTP version used in the request is not supported by the server.
pub const http_version_not_supported = 505

/// 506 Variant Also Negotiates - The server has an internal configuration error.
pub const variant_also_negotiates = 506

/// 507 Insufficient Storage - The server is unable to store the representation needed to complete the request.
pub const insufficient_storage = 507

/// 508 Loop Detected - The server detected an infinite loop while processing the request.
pub const loop_detected = 508

/// 510 Not Extended - Further extensions to the request are required for the server to fulfill it.
pub const not_extended = 510

/// 511 Network Authentication Required - The client needs to authenticate to gain network access.
pub const network_authentication_required = 511
