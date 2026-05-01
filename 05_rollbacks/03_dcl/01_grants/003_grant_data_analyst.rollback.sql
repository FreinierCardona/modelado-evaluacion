
-- Revocar los SELECT otorgados al rol role_data_analyst en sch_payment

REVOKE SELECT ON sch_payment.payment FROM role_data_analyst;
REVOKE SELECT ON sch_payment.payment_transaction FROM role_data_analyst;
REVOKE SELECT ON sch_payment.refund FROM role_data_analyst;
REVOKE SELECT ON sch_payment.payment_status FROM role_data_analyst;
REVOKE SELECT ON sch_payment.payment_method FROM role_data_analyst;

REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_payment FROM role_data_analyst;
