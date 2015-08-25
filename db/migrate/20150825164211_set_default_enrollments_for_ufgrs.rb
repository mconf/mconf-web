# coding: utf-8
class SetDefaultEnrollmentsForUfgrs < ActiveRecord::Migration
  def change
    enrollments = ["Docente", "Técnico-Administrativo", "Funcionário de Fundações da UFRGS",
                   "Tutor de disciplina", "Professor visitante", "Colaborador convidado"]
    Site.current.update_attributes(allowed_to_record: enrollments)
  end
end
