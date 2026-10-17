import gleeunit
import gleeunit/should
import hinoto/status

pub fn main() {
  gleeunit.main()
}

// Test 1xx Informational status codes
pub fn informational_status_codes_test() {
  status.continue |> should.equal(100)
  status.switching_protocols |> should.equal(101)
  status.processing |> should.equal(102)
  status.early_hints |> should.equal(103)
}

// Test 2xx Success status codes
pub fn success_status_codes_test() {
  status.ok |> should.equal(200)
  status.created |> should.equal(201)
  status.accepted |> should.equal(202)
  status.non_authoritative_information |> should.equal(203)
  status.no_content |> should.equal(204)
  status.reset_content |> should.equal(205)
  status.partial_content |> should.equal(206)
  status.multi_status |> should.equal(207)
  status.already_reported |> should.equal(208)
  status.im_used |> should.equal(226)
}

// Test 3xx Redirection status codes
pub fn redirection_status_codes_test() {
  status.multiple_choices |> should.equal(300)
  status.moved_permanently |> should.equal(301)
  status.found |> should.equal(302)
  status.see_other |> should.equal(303)
  status.not_modified |> should.equal(304)
  status.use_proxy |> should.equal(305)
  status.temporary_redirect |> should.equal(307)
  status.permanent_redirect |> should.equal(308)
}

// Test 4xx Client Error status codes
pub fn client_error_status_codes_test() {
  status.bad_request |> should.equal(400)
  status.unauthorized |> should.equal(401)
  status.payment_required |> should.equal(402)
  status.forbidden |> should.equal(403)
  status.not_found |> should.equal(404)
  status.method_not_allowed |> should.equal(405)
  status.not_acceptable |> should.equal(406)
  status.proxy_authentication_required |> should.equal(407)
  status.request_timeout |> should.equal(408)
  status.conflict |> should.equal(409)
  status.gone |> should.equal(410)
  status.length_required |> should.equal(411)
  status.precondition_failed |> should.equal(412)
  status.content_too_large |> should.equal(413)
  status.uri_too_long |> should.equal(414)
  status.unsupported_media_type |> should.equal(415)
  status.range_not_satisfiable |> should.equal(416)
  status.expectation_failed |> should.equal(417)
  status.misdirected_request |> should.equal(421)
  status.unprocessable_content |> should.equal(422)
  status.locked |> should.equal(423)
  status.failed_dependency |> should.equal(424)
  status.too_early |> should.equal(425)
  status.upgrade_required |> should.equal(426)
  status.precondition_required |> should.equal(428)
  status.too_many_requests |> should.equal(429)
  status.request_header_fields_too_large |> should.equal(431)
  status.unavailable_for_legal_reasons |> should.equal(451)
}

// Test 5xx Server Error status codes
pub fn server_error_status_codes_test() {
  status.internal_server_error |> should.equal(500)
  status.not_implemented |> should.equal(501)
  status.bad_gateway |> should.equal(502)
  status.service_unavailable |> should.equal(503)
  status.gateway_timeout |> should.equal(504)
  status.http_version_not_supported |> should.equal(505)
  status.variant_also_negotiates |> should.equal(506)
  status.insufficient_storage |> should.equal(507)
  status.loop_detected |> should.equal(508)
  status.not_extended |> should.equal(510)
  status.network_authentication_required |> should.equal(511)
}

// Test commonly used status codes
pub fn common_status_codes_test() {
  // Most commonly used success codes
  status.ok |> should.equal(200)
  status.created |> should.equal(201)
  status.no_content |> should.equal(204)

  // Most commonly used client error codes
  status.bad_request |> should.equal(400)
  status.unauthorized |> should.equal(401)
  status.forbidden |> should.equal(403)
  status.not_found |> should.equal(404)
  status.method_not_allowed |> should.equal(405)

  // Most commonly used server error codes
  status.internal_server_error |> should.equal(500)
  status.bad_gateway |> should.equal(502)
  status.service_unavailable |> should.equal(503)
}
