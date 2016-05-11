class SuffixLinker

  def update(location)
    if ((@nodeNeedingSuffixLink != nil) && (location.node != @nodeNeedingSuffixLink) && location.onNode) then
      @nodeNeedingSuffixLink.suffixLink = location.node
      @nodeNeedingSuffixLink = nil
    end
  end

  def nodeNeedingSuffixLink(node)
    if (@nodeNeedingSuffixLink != nil) then
      @nodeNeedingSuffixLink.suffixLink = node
    end
    @nodeNeedingSuffixLink = node
  end
end