-- 002_inserts_sch_identity.rollback.sql
-- Rollback para inserts de sch_identity
BEGIN;

-- eliminar contactos
DELETE FROM sch_identity.person_contact WHERE contact_value IN (
  'person1@example.com','person2@example.com','person3@example.com','person4@example.com','person5@example.com',
  'person6@example.com','person7@example.com','person8@example.com','person9@example.com','person10@example.com'
);

-- eliminar documentos
DELETE FROM sch_identity.person_document WHERE document_number IN (
  'DOC-001','DOC-002','DOC-003','DOC-004','DOC-005','DOC-006','DOC-007','DOC-008','DOC-009','DOC-010'
);

-- eliminar personas (por nombre de prueba)
DELETE FROM sch_identity.person WHERE first_name SIMILAR TO 'TestFirst%';

-- eliminar catálogos
DELETE FROM sch_identity.contact_type WHERE type_code LIKE 'CT%';
DELETE FROM sch_identity.document_type WHERE type_code LIKE 'DT%';
DELETE FROM sch_identity.person_type WHERE type_code LIKE 'PT%';

COMMIT;
