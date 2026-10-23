# typed: strict
# frozen_string_literal: true

# Compares clean absolute paths' components directly rather than through `cleanpath`.
module FastRelativePathExtension
  extend T::Helpers

  requires_ancestor { Pathname }

  sig { params(base_directory: T.anything).returns(Pathname) }
  def relative_path_from(base_directory)
    case base_directory
    when String, Pathname
      path = to_s
      base = base_directory.to_s
      if File::FNM_SYSCASE.zero? && clean_absolute_path?(path) && clean_absolute_path?(base)
        path_names = path.split("/").drop(1)
        base_names = base.split("/").drop(1)
        common = 0
        common += 1 while common < path_names.length && path_names[common] == base_names[common]
        names = Array.new(base_names.length - common, "..") + path_names.drop(common)
        return Pathname.new(names.empty? ? "." : File.join(*names))
      end
    end

    super
  end

  private

  # Paths with a component starting with `.` also take the `super` path.
  sig { params(path: String).returns(T::Boolean) }
  def clean_absolute_path?(path)
    path.start_with?("/") && path.exclude?("//") && path.exclude?("/.") && (path == "/" || !path.end_with?("/"))
  end
end
