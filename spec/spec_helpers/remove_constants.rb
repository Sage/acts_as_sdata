def remove_constants(*constants)
  constants.each do |constant|
    Object.__send__(:remove_const, constant) if Object.__send__(:const_defined?, constant)
  end
end
