require File.join(File.dirname(__FILE__), 'helper')

describe SRT::Shell do
  before do
    @app = SRT::Shell.new
  end

  it "should return a SRT::Shell" do
    expect(@app.class).to eq(SRT::Shell)
  end

  it "should load a file" do
    expect{ @app.load_path(File.dirname(__FILE__) + '/fixtures/sample.srt') }.to_not raise_error(Exception)

  end

  it 'should print out its USAGE' do
    expect(STDOUT).to receive(:puts).with(SRT::Shell::USAGE_MSG)
    @app.eval_command('help')
  end

  describe "With a loaded SRT file" do
    before do
      @app.load_path(File.dirname(__FILE__) + '/fixtures/sample.srt')
    end

    it "should show a line" do
      expect(STDOUT).to receive(:puts).with(
        "1\n00:03:55,339 --> 00:03:57,236\nI had the craziest dream last night.\n\n"
      )
      @app.eval_command('show 1')
    end

    it "should forward SRT file's time" do
      @app.eval_command('forward 1 1')
      expect(STDOUT).to receive(:puts).with(
        "1\n00:03:55,340 --> 00:03:57,237\nI had the craziest dream last night.\n\n"
      )
      @app.eval_command('show 1')
    end

    it "should rewind SRT file's time" do
      @app.eval_command('rewind 1 1')
      expect(STDOUT).to receive(:puts).with(
        "1\n00:03:55,338 --> 00:03:57,235\nI had the craziest dream last night.\n\n"
      )
      @app.eval_command('show 1')
    end

    it "should show a message when an invalid index is used for rewind/forward" do
      expect(STDOUT).to receive(:puts).with(/Invalid/)
      @app.eval_command('rewind 0  1')
    end

    it "should scan for lines' interval" do
      expect(STDOUT).to receive(:puts).with(
<<OUT
1
00:03:55,339 --> 00:03:57,236
I had the craziest dream last night.

4
00:04:10,566 --> 00:04:12,193
It was the prologue,
OUT
)
      @app.eval_command('interval 3000')
    end

    it "should remove a line from SRT::File" do
      @app.eval_command('remove 1')
      expect(STDOUT).to receive(:puts).with(
<<OUT
1
00:03:59,679 --> 00:04:01,586
I was dancing the White Swan.

OUT
      )
      @app.eval_command('show 1')
    end

    it "should return the lines containing the searched term" do
      expect(STDOUT).to receive(:puts).with(
<<OUT
2
00:03:59,679 --> 00:04:01,586
I was dancing the White Swan.

OUT
      )
      @app.eval_command('search dancing')
    end
  end
end
