module XPathBaker
  module HTML
    module Table

      def table(*args)
        XPath.new(:table).build(*args)
      end

    end
  end
end
