class axi_slave_core_v_sequence extends uvm_sequence #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_object_utils(axi_slave_core_v_sequence)

  // Constructor
  function new (string name = "axi_slave_core_v_sequence");
    super.new(name);
  endfunction

  // Declaration of P Sequencer
  `uvm_declare_p_sequencer(axi_slave_core_v_sequencer)

  // Sequncers && Sequences handels
  rd_trans_sequencer m_rd_trans_seqr;
  wr_trans_sequencer m_wr_trans_seqr;

  wr_trans_sequence m_wr_trans_seq;
  rd_trans_sequence m_rd_trans_seq;


  //-------------------------------------------
  // PRE_BODY
  //-------------------------------------------
  task pre_body;
    m_wr_trans_seq = wr_trans_sequence::type_id::create("m_wr_trans_seq");
    m_rd_trans_seq = rd_trans_sequence::type_id::create("m_rd_trans_seq");

    m_wr_trans_seqr = p_sequencer.m_wr_trans_seqr;
    m_rd_trans_seqr = p_sequencer.m_rd_trans_seqr;
  endtask

  //-------------------------------------------
  // BODY
  //-------------------------------------------
  task body;
    fork
      begin
        m_wr_trans_seq.start(m_wr_trans_seqr);
      end

      begin
        m_rd_trans_seq.start(m_rd_trans_seqr);
      end
    join_any

  endtask

endclass
