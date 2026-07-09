module hazard_detection_unit(
    input id_ex_MemRead,
    input [4:0] id_ex_rd,

    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,

    output stall
);

assign stall =
    id_ex_MemRead &&
    (id_ex_rd != 0) &&
    (
        (id_ex_rd == if_id_rs1) ||
        (id_ex_rd == if_id_rs2)
    );

endmodule