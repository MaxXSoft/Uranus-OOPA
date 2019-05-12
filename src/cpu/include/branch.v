// some definitions about branch prediction
`define GHR_WIDTH   5
`define GHR_BUS     (`GHR_WIDTH) - 1:0
`define PHT_SIZE    (2 ** (`GHR_WIDTH))
`define BTB_SIZE    64
