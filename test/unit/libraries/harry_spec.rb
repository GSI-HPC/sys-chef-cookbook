describe 'Sys::Harry' do

  before do
    require_relative '../../../libraries/sys_harry.rb'
    class Dummy
    end
    @dummy = Dummy.new
    @dummy.extend(Sys::Harry)
  end

  it 'should render config' do
    @single_value = @dummy.generate_harry_config({section: { option: 'value'}}, 0)
    expect(@single_value).to match(/\[section\]/)
    expect(@single_value).to match(/^option = value$/)
  end

  it 'should render subgroups' do
    @sub_group = @dummy.generate_harry_config({section: {group: { sub: 'group'}}}, 0)
    expect(@sub_group).to eq <<-EOF.strip
[section]
group = {
        sub = group
}
EOF
  end

  it 'should not put spaces around separator' do
    hash = {section: {group: {sub: 'group'}}}
    flags = {spaces_around_separator: false}
    indent = 0
    config = @dummy.generate_harry_config(hash, indent, flags)
    expect(config).to eq <<-EOF.strip
[section]
group={
        sub=group
}
EOF
  end

  it 'uses indentation' do
    hash = {section: {group: {sub: 'group'}}}
    flags = {indentation: "\t"}
    indent = 0
    config = @dummy.generate_harry_config(hash, indent, flags)
    expect(config).to eq <<-EOF.strip
[section]
group = {
\tsub = group
}
EOF
  end

  it 'uses alignment' do
    hash = {section: {group: {sub: 'group', longsub: 'group2'}}}
    indent = 0
    config = @dummy.generate_harry_config(hash, indent)
    expect(config).to eq <<-EOF.strip
[section]
group = {
        sub     = group
        longsub = group2
}
EOF
  end

  it 'does not use alignment' do
    hash = {section: {group: {sub: 'group', longsub: 'group2'}}}
    flags = {alignment: false}
    indent = 0
    config = @dummy.generate_harry_config(hash, indent, flags)
    expect(config).to eq <<-EOF.strip
[section]
group = {
        sub = group
        longsub = group2
}
EOF
  end

  it 'uses another separator' do
    hash = {section: {group: {sub: 'group', longsub: 'group2'}}}
    indent = 0
    flags = {spaces_around_separator: false, separator: ': ',
    alignment: false}
    config = @dummy.generate_harry_config(hash, indent, flags)
    expect(config).to eq <<-EOF.strip
[section]
group: {
        sub: group
        longsub: group2
}
EOF
  end

end
