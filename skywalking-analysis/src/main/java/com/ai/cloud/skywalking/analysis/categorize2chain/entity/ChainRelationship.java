package com.ai.cloud.skywalking.analysis.categorize2chain.entity;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.hadoop.hbase.client.Put;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ai.cloud.skywalking.analysis.categorize2chain.po.ChainInfo;
import com.ai.cloud.skywalking.analysis.categorize2chain.util.HBaseUtil;
import com.ai.cloud.skywalking.analysis.config.HBaseTableMetaData;
import com.google.gson.GsonBuilder;

public class ChainRelationship {
    private static Logger logger = LoggerFactory.getLogger(ChainRelationship.class.getName());

    private String key;
    private Map<String, CategorizedChainInfo> categorizedChainInfoMap = new HashMap<String, CategorizedChainInfo>();
    private Set<UncategorizeChainInfo> uncategorizeChainInfoSet = new HashSet<UncategorizeChainInfo>();
    private Map<String, ChainDetail> chainDetailMap = new HashMap<String, ChainDetail>();

    public ChainRelationship(String key) {
        this.key = key;
    }

    private void categoryAllUncategorizedChainInfo(CategorizedChainInfo parentChains) {
        if (uncategorizeChainInfoSet != null && uncategorizeChainInfoSet.size() > 0) {
            Iterator<UncategorizeChainInfo> uncategorizeChainInfoIterator = uncategorizeChainInfoSet.iterator();
            while (uncategorizeChainInfoIterator.hasNext()) {
                UncategorizeChainInfo uncategorizeChainInfo = uncategorizeChainInfoIterator.next();
                if (parentChains.isContained(uncategorizeChainInfo)) {
                    parentChains.add(uncategorizeChainInfo);
                    uncategorizeChainInfoIterator.remove();
                }
            }
        }
    }

    private void try2CategoryUncategorizedChainInfo(UncategorizeChainInfo child) {
        boolean isContained = false;
        for (Map.Entry<String, CategorizedChainInfo> entry : categorizedChainInfoMap.entrySet()) {
            if (entry.getValue().isAlreadyContained(child)) {
                isContained = true;
            } else if (entry.getValue().isContained(child)) {
                logger.info("There has contained :" + entry.getKey() + "  " + child.getCID());
                entry.getValue().add(child);
                chainDetailMap.put(child.getCID(), new ChainDetail(child.getChainInfo(), false));
                isContained = true;
            }
        }

        if (!isContained) {
            if (!uncategorizeChainInfoSet.contains(child)) {
                chainDetailMap.put(child.getCID(), new ChainDetail(child.getChainInfo(), false));
                uncategorizeChainInfoSet.add(child);
            }
        }

    }

    private CategorizedChainInfo addCategorizedChain(ChainInfo chainInfo) {
        if (!categorizedChainInfoMap.containsKey(chainInfo.getCID())) {
            categorizedChainInfoMap.put(chainInfo.getCID(),
                    new CategorizedChainInfo(chainInfo));

            chainDetailMap.put(chainInfo.getCID(), new ChainDetail(chainInfo, true));
        }
        return categorizedChainInfoMap.get(chainInfo.getCID());
    }

    public void categoryChain(ChainInfo chainInfo) {
        if (chainInfo.getChainStatus() == ChainInfo.ChainStatus.NORMAL) {
            CategorizedChainInfo categorizedChainInfo = addCategorizedChain(chainInfo);
            categoryAllUncategorizedChainInfo(categorizedChainInfo);
        } else {
            UncategorizeChainInfo uncategorizeChainInfo = new UncategorizeChainInfo(chainInfo);
            try2CategoryUncategorizedChainInfo(uncategorizeChainInfo);
        }
    }

    public void save() throws SQLException, IOException, InterruptedException {
    	saveChainRelationship();
        saveChainDetail();
    }

    private void saveChainDetail() throws SQLException, IOException, InterruptedException {
        List<Put> puts = new ArrayList<Put>();
        for (Map.Entry<String, ChainDetail> entry : chainDetailMap.entrySet()) {
            Put put1 = new Put(entry.getKey().getBytes());
            entry.getValue().save(put1);
            puts.add(put1);
        }


        try {
            HBaseUtil.saveChainDetails(puts);
        } catch (IOException e) {
            logger.error("Faild to save chain detail to hbase.", e);
            throw e;
        } catch (InterruptedException e) {
            logger.error("Faild to save chain detail to hbase.", e);
            throw e;
        }
    }

    private void saveChainRelationship() throws IOException {
        Put put = new Put(getKey().getBytes());

        put.addColumn(HBaseTableMetaData.TABLE_CALL_CHAIN_RELATIONSHIP.COLUMN_FAMILY_NAME.getBytes(), HBaseTableMetaData.TABLE_CALL_CHAIN_RELATIONSHIP.UNCATEGORIZE_COLUMN_NAME.getBytes()
                , new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create().toJson(getUncategorizeChainInfoList()).getBytes());

        for (Map.Entry<String, CategorizedChainInfo> entry : getCategorizedChainInfoMap().entrySet()) {
            put.addColumn(HBaseTableMetaData.TABLE_CALL_CHAIN_RELATIONSHIP.COLUMN_FAMILY_NAME.getBytes(), entry.getKey().getBytes()
                    , entry.getValue().toString().getBytes());
        }

        try {
            HBaseUtil.saveChainRelationship(put);
        } catch (IOException e) {
            logger.error("Faild to save chain relationship to hbase.", e);
            throw e;
        }
    }

    public void addCategorizeChain(String qualifierName, CategorizedChainInfo categorizedChainInfo) {
        categorizedChainInfoMap.put(qualifierName, categorizedChainInfo);
    }

    public String getKey() {
        return key;
    }

    public Map<String, CategorizedChainInfo> getCategorizedChainInfoMap() {
        return categorizedChainInfoMap;
    }

    public Set<UncategorizeChainInfo> getUncategorizeChainInfoList() {
        return uncategorizeChainInfoSet;
    }

    public void addUncategorizeChain(List<UncategorizeChainInfo> uncategorizeChainInfos) {
        uncategorizeChainInfoSet.addAll(uncategorizeChainInfos);
    }
}
